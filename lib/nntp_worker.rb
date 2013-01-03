require './lib/nntp/client'
require 'digest/md5'

class NNTPWorker
  include Celluloid
  include Celluloid::Logger

  def self.part_regexp
     /\(((?<part_number>\d+))\/((?<total_parts>\d+))\)$/i
  end

  def initialize(db, config) 
    @config = config  
    @db = db
    server = @config['nntp_server']
    @nntp = Nntp::Client.new
    @nntp.connect(server['host'], server['port'], server['ssl'])
    @nntp.authenticate(server['username'], server['password'])
    info "Connected to #{server['host']}:#{server['port']}"
  end


  def update_stats(group_id)    
    group = @db[:groups].where('id = ?', group_id).first
    return unless group.present?
    info "Update stats for #{group[:name]}"
    group_info = @nntp.set_group(group[:name])    
    @db[:groups].where('id = ?', group_id).update(count: group_info[:article_count], low: group_info[:first], high: group_info[:last], crawled_at: Time.now)
  end

  def crawl(group_id)
    group = @db[:groups].where('id = ?', group_id).first
    return unless group.present?
    
    row_count = @db[:groups].where('id = ? AND (locked_at IS NULL OR locked_at <= ?)', group[:id], @config['lock_timeout_mins'].minutes.ago).update(locked_at: Time.now)
    if row_count == 0
      info "Couldn't obtain lock on #{group[:name]}"
      return
    end
    @nntp.set_group(group[:name])
    highest_crawled = group[:highest_crawled] || (group[:high] - @config['page_size'] + 1)
    range = "#{highest_crawled}-#{highest_crawled + @config['page_size']}"
    overview = @nntp.x_overview(range)

    @db.transaction do

      highest_returned = highest_crawled

      bins = {}
      overview.each do |a|
        if match = a[:subject].match(NNTPWorker.part_regexp)
          subject = a[:subject].gsub(NNTPWorker.part_regexp, '').strip.encode('utf-8', invalid: :replace, undef: :replace)
            unless bins.has_key?(subject)
              bins.merge!(subject => {
                :total_parts => match['total_parts'].to_i,
                :poster => a[:from].encode('utf-8', invalid: :replace, undef: :replace),
                :date => a[:date],
                :parts => []
              })
            end
            bins[subject][:parts] << {
              :part_number => match['part_number'].to_i,
              :message_id => a[:message_id],
              :article_id => a[:article_id],
              :size => a[:bytes]
            }
        end
        highest_returned = a[:article_id] if a[:article_id] > highest_returned
      end
      
      # Store all the stuff we found. TODO: bulk operations on parts?
      bins.each do |subject, data|
        md5 = Digest::MD5.hexdigest("#{subject}#{data[:poster]}#{group[:id]}")
        binary = @db[:binaries].where('binary_md5 = ?', md5).first
        binary_id = nil
        if binary.blank?
          binary_id = @db[:binaries].insert(binary_md5: md5, 
                                name: subject,
                                total_parts: data[:total_parts],
                                poster: data[:poster],
                                date: data[:date],
                                group_id: group[:id])
        else
          binary_id = binary[:id]
        end

        data[:parts].each do |p|
          # There might be a better way to avoid inserting duplicates on postgres without raising errors
          # but I don't know how! 
          row_count = @db[:binary_parts].where(binary_id: binary_id, part_number: p[:part_number]).update(message_id: p[:message_id], article_id: p[:article_id], size: p[:size])
          if row_count == 0         
            @db[:binary_parts].insert(binary_id: binary_id,
                                      part_number: p[:part_number],
                                      message_id: p[:message_id],
                                      article_id: p[:article_id],
                                      size: p[:size])
          end
        end
      end


      @db[:groups].where('id = ?', group[:id]).update(crawled_at: Time.now, highest_crawled: highest_returned, locked_at: nil)
    end

  end

end