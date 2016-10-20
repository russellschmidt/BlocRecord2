require 'sqlite3'

module Selection
	def get_min
		min = connection.execute <<-SQL
			SELECT id FROM #{table}
			ORDER BY id ASC LIMIT 1;
		SQL
		min[0][0]
	end

	def get_max
		max = connection.execute <<-SQL
			SELECT id FROM #{table}
			ORDER BY id DESC LIMIT 1;
		SQL
		max[0][0]
	end

	def find(*ids)
		# if there is just one id, we call find_one, which returns a model object
		# otherwise we pass in the arguments
		# then use join to convert them into a comma-delimited string that SQL will like
		# Then we call rows_to_array to do as the name says, return the found rows as an array

		# error handling for ids - make sure its within range of min and max
		# future implementation - check if id in range and not deleted

		if ids.length == 1
			if ids.is_a? Integer
				if ids >= max || ids <= min
					puts "record id out of range"
				else
					find_one(ids.first)
				end
			else
				puts "Invalid id data type"
			end
		else
			ids_in_range = true
			ids_valid = true
			ids.each do |id|
				if id.is_a? Integer
					if id < min || id > max
						ids_in_range = false
					end
				else
					ids_valid = false
					puts "Invalid id data type"
				end
			end

			if ids_in_range && ids_valid
				rows = connection.execute <<-SQL
					SELECT #{columns.join ","} FROM #{table}
					WHERE id IN (#{ids.join(",")});
				SQL

				rows_to_array(rows)
			else
				puts "ids out of range"
			end
		end
	end


	def find_one(id)
		# straight-forward SELECT that returns the row matching the id passed in
		# By using columns instead of (*) we can manipulate this method later
		row = connection.get_first_row <<-SQL
			SELECT #{columns.join ","} FROM #{table}
			WHERE id = #{id};
		SQL

		init_object_from_row(row)
	end


	def find_by(attribute, value)
		# here we return the first match where attribute == value for the record
		# we rely on init_object_from_row to return an object

		# first, check for proper data types / not null

		if attribute && attribute.is_a?(Symbol) && value
		
			row = connection.get_first_row <<-SQL
				SELECT #{columns.join ","} FROM #{table}
				WHERE #{attribute} = #{BlocRecord::Utility.sql_strings(value)};
			SQL

			init_object_from_row(row)
		else
			puts "attribute must be a string and value cannot be null for find_by"
		end
	end


	def take_one
		# Here we are just grabbing a random row from the table
		row = connection.get_first_row <<- SQL
			SELECT #{columns.join ","} FROM #{table}
			ORDER BY random()
			LIMIT 1;
		SQL

		init_object_from_row(row)
	end


	def take(num=1)
		# similar to take_one() but with a variable number of return random items as an array
		# if single num or no num passed in, returns object courtesy take_one()

		# let's make sure num is an integer
		# if it is an integer, lets make sure it is a positive number and less than set count

		if num.is_a? Integer
			if num > 0 && num <= self.count
				if num > 1
					rows = connection.execute <<-SQL
						SELECT #{columns.join ","} FROM #{table}
						ORDER BY random()
						LIMIT #{num};
					SQL
				else
					take_one
				end
			else
				puts "Number of items to take is out of range"
			end
		else
			puts "Argument is not a valid number"
		end
	end

	# first() and last() return first or last object in the database
	def first
		row = connection.get_first_row <<-SQL
			SELECT #{columns.join ","} FROM #{table}
			ORDER BY id
			ASC LIMIT 1;
		SQL

		init_object_from_row(row)
	end

	def last
		row = connection.get_first_row <<-SQL
			SELECT #{columns.join ","} FROM #{table}
			ORDER BY id
			DESC LIMIT 1;
		SQL

		init_object_from_row(row)
	end


	def all
		rows = connection.execute <<-SQL
			SELECT #{columns.join ","} FROM #{table};
		SQL

		rows_to_array(rows)
	end


	def method_missing(method, *arguments, &block)
		if method.downcase.match(/find_by_/)
			columnName = method.slice( ('find_by_'.length)..(method.length) ).to_sym
			find_by(columnName, *arguments)
		else
			super(method, *arguments, &block)
		end
	end


	def find_each(start:, batch_size:)
		if start && batch_size && start.is_a?(Integer) && batch_size.is_a?(Integer)
			if start >= 0 && batch_size > 0
				
			rows = connection.execute <<-SQL
				SELECT #{columns.join ","} FROM #{table}
				LIMIT #{batch_size} 
				OFFSET #{start};
			SQL
	
			rows_to_array(rows).each{ |row| yield row }

			else
				puts "Method arguments invalid as start: greater than or equal to 0, batch_size: greater than 0."
			end

		elsif !start && !batch_size
			rows = connection.execute <<-SQL
				SELECT #{columns.join ","} FROM #{table}
			SQL

			rows_to_array(rows).each{ |row| yield row }
		else
			puts "Please use valid integer arguments for start:, batch_size:"
		end
	end


	def find_in_batches(start:, batch_size:)
		if start && batch_size && start.is_a?(Integer) && batch_size.is_a?(Integer)
			if start >= 0 && batch_size > 0
				
				rows = connection.execute <<-SQL
					SELECT #{columns.join ","} FROM #{table}
					LIMIT #{batch_size} 
					OFFSET #{start};
				SQL

				yield rows_to_array(rows)

			else
				puts "start: must be at least zero and batch_size: greater than zero"
			end
		else
			puts "start:, batch_size: arguments can't be nil and must be integers."
		end
	end


	private

	def init_object_from_row(row)
		# if the row exists, we take the passed in data and return it as a hash (model object)
		# "column_name" => [val1, val2...]
		if row
			data = Hash[columns.zip(row)]
			new(data)
		end
	end

	def rows_to_array(rows)
		# this method maps an array of rows to an array of matched model objects.
		# the return is an array of record objects, where each object is from 
		rows.map { |row| new(Hash[columns.zip(row)]) }
	end
end