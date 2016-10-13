require 'sqlite3'

module Selection
	def find(id)
		# straight forward SELECT that returns the row matching the id passed in
		# why we are using columns instead of (*)?
		row = connection.get_first_row <<-SQL
			SELECT #{columns.join ","} FROM #{table}
			WHERE id = #{id};
		SQL

		# then we take the returned SQL data, hash it, and return it
		# "column_name" => [val1, val2...]
		data = Hash[columns.zip(row)]
		new(data)
	end
end