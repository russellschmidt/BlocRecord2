require 'sqlite3'
require 'bloc_record/utility'

module Schema
	def table
		# returns the corrected SQL table name on the class that calls it
		BlocRecord::Utility.underscore(name)
	end

	def columns
		# schema defined as a hash where column names are keys, column types are the values
		# so this just returns the columns / keys in the db as an array of strings
		schema.keys
	end

	def attributes
		# returns all of the columns except for the id column. That is just substraction.
		# Array[x,y,z] - Array[z] = Array[x,y]. You learn something every day.
		columns - ["id"]
	end

	def schema
		# here, unless schema already exists, we iterate through the database table.
		# we create and return a key-value pair of key = 'column/attribute name' and value = 'type'
		unless @schema
			@schema = {}
			connection.table_info(table) do |col|
				@schema[col["name"]] = col["type"]
			end
		end
		@schema
	end

	def count
		# the <<- is a heredoc operator that tells Ruby to send everything between the enclosing SQL
		# to 'execute' as an argument, sending in SQL syntax that provides a count in this case.
		# the [0][0] is because connection.execute() returns a 2d array, and the count is in [0][0]
		connection.execute(<<-SQL)[0][0]
			SELECT COUNT(*) FROM #{table}
		SQL
	end

end