module BlocRecord
	module Utility
		# self refers to the Utility class
		# this allows you to call underscore just like a class method
		# BlocRecord::Utility.underscore('SomeText')
		# because self is a reference to the current object
		extend self

		def underscore(camel_cased_word)
			if camel_cased_word.is_a? String
				# converts CamelCase to SQL-friendly snake case
	      string = camel_cased_word.gsub(/::/, '/')
	      string.gsub!(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
	      string.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
	      string.tr!("-", "_")
	      string.downcase
	    else
	    	puts "Not a valid data type to convert to snake_case"
	    end
		end

		def sql_strings(value)
			case value
			when String
				# wrap in quotes
				"'#{value}'"
			when Numeric
				# convert to a string
				value.to_s
			else
				"null"
			end
		end

		def convert_keys(options)
			# iterates through keys 
			# takes a hash of key-value pairs and converts the keys to strings if they were symbols
			options.keys.each { |k| options[k.to_s] = options.delete(k) if k.kind_of?(Symbol)}
			options
		end

		def instance_variables_to_hash(obj)
			# this converts the dynamic instance variables we created into a hash, stripping off the '@'
			# opposite of Base::initialize which turns a hash into instance variables
			Hash[obj.instance_variables.map{ |var| ["#{var.to_s.delete('@')}", obj.instance_variable_get(var.to_s)]}]
		end

		def reload_obj(dirty_obj)
			# This method first calls the find_one method on the id, assigning the db object to persisted_obj
			persisted_obj = dirty_obj.class.find_one(dirty_obj.id)
			# Then we iterate over the instance variables which instance_variables returns as an array
			# we get the instance variable value from the database and save that to our local object (dirty_obj)
			# this makes sure we have a nice clean current copy of a record, overwriting unsaved changes.
			dirty_obj.instance_variables.each do |instance_variable|
				dirty_obj.instance_variable_set(instance_variable, persisted_obj.instance_variable_get(instance_variable))
			end
		end

	end

end