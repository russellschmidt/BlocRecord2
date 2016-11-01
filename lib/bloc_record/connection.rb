require 'sqlite3'

module Connection
	# connection method will either instantiate a new database object the first time called
	# or  ||= 
	# return the database onject instance previously set
	def connection
		@connection ||= SQLite3::Database.new(BlocRecord.database_filename)
	end
end