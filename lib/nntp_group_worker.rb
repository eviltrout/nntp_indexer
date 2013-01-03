class NNTPGroupWorker
  include Celluloid
  include Celluloid::Logger

  def initialize(group_id)
    @group_id = group_id  

    work!
  end

  def work
    nntp_pool = Celluloid::Actor[:nntp_pool]
    nntp_pool.update_stats(@group_id)
    
    @last_updated_stats = Time.now
    loop do
      nntp_pool.crawl(@group_id)
      if @last_updated_stats < 5.minute.ago
        nntp_pool.update_stats(@group_id)
        @last_updated_stats = Time.now
      end
    end
  end

end