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


		def take
			# create an array of all of the ids in our db
			# capture a random 

		end


		def where()
		end


		def not()
		end
	end
end