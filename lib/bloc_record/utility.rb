module BlocRecord
	module Utility
		# self refers to the Utility class
		# this allows you to call underscore just like a class method
		# BlocRecord::Utility.underscore('SomeText')
		# because self is a reference to the current object
		extend self

		def underscore(camel_cased_word)
			# converts CamelCase to SQL-friendly snake case
      string = camel_cased_word.gsub(/::/, '/')
      string.gsub!(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
      string.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
      string.tr!("-", "_")
      string.downcase
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

	end

end