class LogManager
	def self.update_log_file(params)
		File.open("/Users/pandurang90/projects/server_logs/log/redevelopment.log") do |f|
			f.puts params[:file_content]
		end
	end
end