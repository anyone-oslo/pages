# encoding: utf-8

module PagesCore
	module ArrayExtensions
		def move_item(index, movement)
			new_index = index + movement
			new_index = 0 if new_index < 0
			new_index = (self.length - 1) if new_index >= self.length
			temp_array = self.reject{ |i| self.index(i) == index }
			temp_array[0...new_index] + [self[index]] + temp_array[new_index..temp_array.length]
		end
	end
end

Array.send(:include, PagesCore::ArrayExtensions)
