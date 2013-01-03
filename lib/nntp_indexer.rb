require 'active_support/core_ext/string'
require 'active_support/core_ext/object'

require './lib/nntp_worker'
require './lib/nntp_group_worker'

class NNTPIndexer
  include Celluloid::Logger

  def initialize(config)
    @config = config
    @db = Sequel.postgres(config['database'])

    @supervisor = Celluloid::SupervisionGroup.new    
    @supervisor.pool(NNTPWorker, size: @config['max_nntp_connections'].to_i, args: [@db, @config], as: :nntp_pool)
  end

  def run
    info "Running..."  
    @db[:groups].all.each do |g|
      @supervisor.supervise(NNTPGroupWorker, [g[:id]])
    end
  end

end