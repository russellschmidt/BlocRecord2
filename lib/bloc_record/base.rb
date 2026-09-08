require 'bloc_record/utility'
require 'bloc_record/schema'
require 'bloc_record/persistence'
require 'bloc_record/selection'
require 'bloc_record/connection'
require 'bloc_record/collection'

module BlocRecord
	class Base
		# grab the modules from the files in 'require' above in this class
		# include -> adds to instance (instance methods)
		# extend -> adds to class (class methods)
    include Persistence
    extend Selection
    extend Schema
    extend Connection

		def initialize(options={})
			# convert the passed in hash 'options' from symbols to strings
			options = BlocRecord::Utility.convert_keys(options)

			# self.class allows us to call a class method from within an instance
			# self.class returns our class name i.e. "Schema" and then call .columns on it.
			# Then we iterate over our column names, dynamically assigning these
			# to instance variables via attr_accessor. Last, we transform the 
			# hash into a variable. Variable name is the key, variable value is the hash value.
			self.class.columns.each do |col|
				self.class.send(:attr_accessor, col)
				self.instance_variable_set("@#{col}", options[col])
			end
		end

	end
end