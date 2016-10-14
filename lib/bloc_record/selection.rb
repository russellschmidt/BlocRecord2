require 'sqlite3'

module Selection
	def find(*ids)
		# if there is just one id, we call find_one, which returns a model object
		# otherwise we pass in the arguments
		# then use join to convert them into a comma-delimited string that SQL will like
		# Then we call rows_to_array to do as the name says, return the found rows as an array
		if ids.length == 1
			find_one(ids.first)
		else
			rows = connection.execute <<-SQL
				SELECT #{columns.join ","} FROM #{table}
				WHERE id IN (#{ids.join(",")});
			SQL

			rows_to_array(rows)
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
		row = connection.get_first_row <<-SQL
			SELECT #{columns.join ","} FROM #{table}
			WHERE #{attribute} = #{BlocRecord::Utility.sql_strings(value)};
		SQL

		init_object_from_row(row)
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
		if num > 1
			rows = connection.execute <<-SQL
				SELECT #{columns.join ","} FROM #{table}
				ORDER BY random()
				LIMIT #{num};
			SQL
		else
			take_one
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

		def rows_to_array(rows)
			# this method maps an array of rows to an array of corresponding model objects
			# columns is an array of the column name and type. 
			# Zip combines in the returned array of values.
			# [col1, val1]
			# Hash 
			rows.map { |row| new(Hash[columns.zip(row)]) }
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
end