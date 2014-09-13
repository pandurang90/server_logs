
require "net/http"
require "uri"

class LogWatcher
  attr_accessor :last_mtime, :log_file,:uri,:request,:log_file_replica

  def initialize(log_file,log_file_replica)
    @log_file = log_file
    raise "File does not exist" unless File.exist?(log_file)
    raise "File does not exist" unless File.exist?(log_file_replica)
    @last_mtime = File.stat(log_file).mtime
    @uri = URI.parse("http://localhost:3001/logs/update_logs")
    @request = Net::HTTP::Post.new(uri.request_uri)
    @log_file_replica = log_file_replica
  end

  def watch(sleep=1)
    loop do
      begin
        Kernel.sleep sleep until file_updated?
      rescue SystemExit,Interrupt
        Kernel.exit
      end
    end
  end

  def file_updated?
    mtime = File.stat(log_file).mtime
    updated = @last_mtime < mtime
    @last_mtime = mtime
    update_file if updated
    puts "updated" if updated
    updated
  end

  def update_file
    file = File.open(log_file, "rb")
    replica_log = File.open(log_file_replica, "rb")
    file_lines = file.readlines
    replica_file_lines = replica_log.readlines
    
    new_logs = ""
    file_lines.each do |e|
      if(!replica_file_lines.include?(e))
        new_logs += e
      end
    end
    file.close
    replica_log.close
    http = Net::HTTP.new(@uri.host, @uri.port)
    request.set_form_data({"file_content" => new_logs})
    response = http.request(request)
  end

end

LogWatcher.new("/Users/pandurang90/projects/server_logs/tmp/test.txt",
  "/Users/pandurang90/projects/server_logs/tmp/replica_test.txt").watch