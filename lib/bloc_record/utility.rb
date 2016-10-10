module BlocRecord
	module Utility
		# self refers to the Utility class
		# this allows you to call underscore just like a class method
		# BlocRecord::Utility.underscore('SomeText')
		# because self is a reference to the current object
		extend self

		def underscore(camel_cased_word)
      string = camel_cased_word.gsub(/::/, '/')
      string.gsub!(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
      string.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
      string.tr!("-", "_")
      string.downcase
		end
	end

end