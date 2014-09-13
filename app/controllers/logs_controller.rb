class LogsController < ApplicationController
	protect_from_forgery except: :update_logs
	def update_logs
		File.open("/Users/pandurang90/projects/server_logs/tmp/replica_test.txt","w") do |f|
			f.puts params[:file_content]
		end
		respond_to do |format|
	      format.html { head :ok }
	    end
	end

	def index
		
	end
end
