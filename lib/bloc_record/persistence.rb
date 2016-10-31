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


		def update_attribute(attribute, value)
			# we pass in the attribute as a symbol
			# then, we pass in the current object's id and turn the updated attribute and value into a hash
			# in order to then call #update, passing these arguments in
			self.class.update(self.id, { attribute => value })
		end


		def update_attributes(updates)
			# updates ought to take the form of `attr: "value", attr2: "value2",...`
			self.class.update(self.id, updates)
		end


		def update(id, updates)
			# convert non-id parameters to an array. Does 'updates' need a splat operator?
			updates = BlocRecord::Utility.convert_keys(updates)
			updates.delete "id"

			# we create an array of strings of format KEY=VALUE
			updates_array = updates.map { |key, value| "#{key}=#{BlocRecord::Utility.sql_strings(value)}" }

			# make the WHERE clause dynamic - if ommitted, update applies to all records
			where_clause = id.nil? ? ";" : "WHERE id = #{id};"

			# Note the closing semicolon is included in the variable `where_clause`
			connection.execute <<-SQL
				UPDATE #{table}
				SET #{updates_array * ","} #{where_clause}
			SQL

			true
		end


		def update_all(updates)
			# we pass in nil for the id which in update will drop the WHERE clause (see: ternary)
			update(nil, updates)
		end
		
	end
end