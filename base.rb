require 'bloc_record/utility'
require 'bloc_record/schema'
require 'bloc_record/persistence'
require 'bloc_record/connection'

module BlocRecord
	class Base
		# include the modules from the files in 'require' above in this class
		extend Persistence
		extend Schema 
		extend Connection

		def initialize(options={})
			# convert the passed in hash 'options' from symbols to strings
			options = BlocRecord::Utility.convert_keys(options)

			# self.class allows us to call a class method from within an instance
			# self.class returns our class name i.e. "Schema" and then call .columns on it.
			# Then we iterate over our column names, dynamically assigning these
			# to instance variables via attr_accessor. Last, we transform the 
			# hash in to a variable. Variable name is the key, Variable value is the hash value.
			self.class.columns.each do |col|
				self.class.send(:attr_accessor, col)
				self.instance_variable_set("@#{col}", options[col])
			end
		end

	end
end