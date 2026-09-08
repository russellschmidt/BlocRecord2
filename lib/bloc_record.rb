module BlocRecord
	# class method for setting filename to an instance variable
	def self.connect_to(filename)
		@database_filename = filename
	end

	# class method for getting filename from instance variable
	def self.database_filename
		@database_filename
	end
end