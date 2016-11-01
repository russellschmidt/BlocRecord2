require 'sqlite3'
require 'bloc_record/schema'

module Persistence
	def self.included(base)
		# this is called whenever the module is included
		# which means, we extend the ClassMethods module automatically when the module is included
		base.extend(ClassMethods)
	end

	module ClassMethods
		def create(attrs)
			# we sql-ify the passed in attrs hash (which will form database attribute: value pairs)
			attrs = BlocRecord::Utility.convert_keys(attrs)
			attrs.delete "id"
			
			# we go through each attributes element (column heading) 
			# we assign the attrs values to an array in order of the attributes to make it SQL-ready
			vals = attributes.map { |key| BlocRecord::Utility.sql_strings(attrs[key]) }

			# join of course takes an array and converts it to a string with values separated by the
			# passed-in delimiter
			connection.execute <<-SQL
				INSERT INTO #{table} (#{attributes.join ","})
				VALUES (#{vals.join ","});
			SQL

			# data is a hash of attributes and values, with .zip converting arguments to arrays
			# so data ends up being a collection of hashes of column_name: [val1, val2...]
			data = Hash[attributes.zip attrs.values]
			
			# last_insert_rowid[0][0] returns the 1st element of the most recent successful insert
			# so here we are setting the hash id value to the SQL row ID.
			data["id"] = connection.execute("SELECT last_insert_rowid();")[0][0]
			# 
			new(data)
		end


		def update(ids, updates)
			# if updates is an array already, it is the multiple record update case (chkpt 5, q1)
			if updates.is_a? Array && updates.is_a? Array
				
				attributes = updates.each.keys
				values = updates.each.values

				# check that we don't have any nil values in 'values'
				if values.flatten.count < attributes.count
					puts "Cannot update an address book entry to empty or nil value"
					return false
				else

					# put ids, updates into an array of arrays [[id1,attr1,val1],[id2,attr2,val2]...]
					updates_array = ids.zip(attributes, values)

					# iterate over the array of arrays
					# # use 'if' sql statement, format:  
					# # # name = IF(id=1, 'Bob'), 
					# # # email= IF(id=2, 'bob@aol.com')..."
					sql_updates << updates_array.each do |row|
						"#{row[1]}=IF(id=#{row[0]},'#{row[2]}'"
					end

					connection.execute <<-SQL
						UPDATE #{table} 
						SET #{sql_updates.join(",")}
						WHERE id IN (#{ids.join(",")});
					SQL

			else
				# convert non-id parameters to an array (original checkpoint work)
				updates = BlocRecord::Utility.convert_keys(updates)
				updates.delete "id"

				# we create an array of strings of format KEY=VALUE
				updates_array = updates.map { |key, value| "#{key}=#{BlocRecord::Utility.sql_strings(value)}" }

				# make the WHERE clause dynamic - if omitted, update applies to all records

				if ids.class == Fixnum
					where_clause = "WHERE id = #{ids};"
				elsif ids.class == Array
					where_clause = ids.empty? ? ";" : "WHERE id IN (#{ids.join(",")};"
				else
					where_clause = ";"
				end

				# Note the closing semicolon is included in the variable `where_clause`
				connection.execute <<-SQL
					UPDATE #{table}
					SET #{updates_array * ","} #{where_clause}
				SQL
			end

			true
		end


		def update_all(updates)
			# we pass in nil for the id which in update will drop the WHERE clause (see: ternary)
			update(nil, updates)
		end


		def update_attribute(attribute, value)
			# we pass in the attribute as a symbol
			# then, we pass in the current object's id and turn the updated attribute and value into a hash
			# in order to then call #update, passing these arguments in
			self.class.update(self.id, { attribute => value })
		end		

		def method_missing(method_name, *args)
			# find if method_name contains 'update'
			# check if phrase after update_ is valid db attribute (phone_number, email or name)
			# # if so, turn that phrase plus first argument into a hash
			# # call update_all(attr: 'value')

			if method_name.match('update_')
				attribute = method_name.slice(7, method_name.length)
				if attribute == 'name' || attribute == 'phone_number' || attribute == 'email'
					update_all({attribute.to_sym => args.first.to_s})
				end
			end

			super(method_name, *args)
		end
	end

	### OUTSIDE OF THE ClassMethod Module
	def save!
		# here we grab all of the column names from the database object's instance variables
		# and set the column name to the (now SQL-ready) value in a comma-separated list,
		# i.e. 'firstname="Fred", lastname="Smith"' which is passed into the SQL UPDATE command.

		# first we have to check to make sure that id exists - it wouldn't if we just created this 
		# object and haven't saved it to the db yet (and therefore wouldn't have an assigned id)
		# So we create the object and save to the database, returning the ID.
		# Then we reload that same object, now with the proper ID included.
		unless self.id
			self.id = self.class.create(BlocRecord::Utility.instance_variables_to_hash(self)).id
			BlocRecord::Utility.reload_obj(self)
			return true
		end

		fields = self.class.attributes.map { |col| "#{col}=#{BlocRecord::Utility.sql_strings(self.instance_variable_get("@#{col}"))}"}.join(",")
		
		self.class.connection.execute <<-SQL
			UPDATE #{self.class.table}
			SET #{fields}
			WHERE id = #{self.id};
		SQL

		true
	end


	def save
		self.save! rescue false
	end


	def update_attributes(updates)
		# updates ought to take the form of `attr: "value", attr2: "value2",...`
		self.class.update(self.id, updates)
	end
end

