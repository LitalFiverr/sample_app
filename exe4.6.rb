def string_shuffle(s)
		s.split('').shuffle.join
end


class String
	def shuffle
		self.split('').shuffle.join
	end
end

person1 = {first:"lital", last:"zubery"}
person2 = {first:"danit", last:"zubery"}
person3 = {first:"alex", last:"litvak"}

params = {father: person1, mother: person2, child:person3}
puts ("child: #{params[:child]}")
puts ("mother: #{params[:mother]}")
puts ("father: #{params[:father]}")