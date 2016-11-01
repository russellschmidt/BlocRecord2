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
				# we want to grab the attr(ibute) and value, check for nil on value, and call #where
				attr = arg.keys.first
				value = arg[attr]
				return self.first.class.where({attr => value}) unless value.nil?
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
				

			else
				puts "#where method requires a hash argument"
				false
			end

		end
	end
end