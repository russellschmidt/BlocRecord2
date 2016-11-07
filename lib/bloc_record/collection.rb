module BlocRecord
	class Collection < Array
		def update_all(updates)
			# we are taking an array of updates as an argument
			# then we set ids as an array
			# lastly we pass in the ids and a hash of updates, if anything is being updated
			# self.first.class.update() uses the update method attached to the first object inside the array

			# return an object of the collection class - return a new collection each time
			# inherit 

			# this line is equivalent to self.map{|obj| obj.id} (?) where obj is self
			# essentially this iterates over the array of model objects and returns an array of their ids
			ids = self.map(&:id)

			self.any? ? self.first.class.update(ids, updates) : false
		end

		def group(*args)
			# note we never define #group_by_ids...
			ids = self.map(&:id)
			self.any? ? self.first.class.group_by_ids(ids, args) : false
		end


		def distinct
			# create an array of name: 'values'
			names = self.map(&:name)
			# returns a single unique value in the array
			# not sure to just return `names.uniq.first`... seems too easy 
			# also not sure this is the unique we are going for as a duplicated value can be returned

			# here we eliminate all entries with duplicates in the closure
			# map leaves us with an array that wil have nil where any repeating elements used to be
			# compact deletes these nil elements, and then 
			# sample returns a remaining unique value at random, default 1 object
			arr.map{ |x| x unless arr.count(x) > 1 }.compact.sample
		end


		def take(num=1)
			# create an array of all of the ids in our db
			# capture a random number
			# return object
			if num.is_a? Fixnum
				if num < 1
					puts "#take requires an integer of 1 or higher"
					false
				else
					ids = self.map(&:id)
					if num > ids.count
						puts "#take can't sample more items than are in the database"
						false
					else
						return self.first.class.find(ids.sample(num))				
					end
				end
			else
				puts "#take requires an integer argument"
				false
			end
		end


		def where(arg)
			# arg ought to be a hash of form {name: 'Bob'}
			if arg.is_a? Hash
				# we want to grab the attr(ibute) and value, check for nil (return all), or kick out bad parameters
				arg_clean = self.first.class.convert_keys(arg)
				return self.first.class.where(arg_clean)
			elsif arg.nil?
				return self.first.class.all
			else
				puts "#where method requires a hash or nil argument"
				false
			end
		end


		def not(arg)
			# arg ought ot be a hash of form {name: 'Bob'}
			# follows #where without arguments (which returns all - see this file, #where)
			if arg.is_a? Hash
				arg_clean = self.first.class.convert_keys(arg)
				attr = arg.keys.first
				value = arg[attr]
				
				rows = connection.execute <<-SQL
					SELECT #{columns.join ","} FROM #{table}
					WHERE #{attr}!=#{value};
				SQL

				rows_to_array(rows)
			else
				puts "#where method requires a hash argument"
				false
			end
		end

		def destroy_all
			# should take an array of instances and delete all of them
			# create an array of the ids of the passed in model object
			ids = self.map(&:id)

			if ids.empty?
				puts "Nothing was deleted." 
			elsif ids.first.is_nil?
				puts "No records were found to delete."
			else
				self.first.class.destroy(ids)
			end
		end

	end
end