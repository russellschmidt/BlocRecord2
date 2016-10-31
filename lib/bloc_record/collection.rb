module BlocRecord
	class Collection < Array
		def update_all(updates)
			# we are taking an array of updates as an argument
			# then we set ids as an array
			# lastly we pass in the ids and a hash of updates, if anything is being updated
			# self.first.class.update() uses the update method attached to the first object inside the array

			# this line is equivalent to self.map{|obj| obj.id} (?) where obj is self
			ids = self.map(&:id)

			self.any? ? self.first.class.update(ids, updates) : false
		end
	end
end