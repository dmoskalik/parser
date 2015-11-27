#!/usr/bin/env ruby

require 'json'
require 'optparse'

file = 'all.json'


OptionParser.new do |opts|
	opts.on('-f', '--file FILE', 'JSON file') { |a|
		file = a
	}

end.parse!

columns = []
json_file = File.read(file)
data = JSON.parse(json_file)

ARGV.each do|a|
	#puts a
	#abort("Invalid input") if isValidInput(a)==false

	if a.include?('!=')
		filters_dif[a.split("!=").first].push(a.split("!=").last)
	elsif a.include?('=')
		filters[a.split("=").first].push(a.split("=").last)
	else
		columns.push(a)
	end
end

def merge(array1, array2)
	result = []

	array1.each do |hash1|
		array2.each do |hash2|
			result.push(hash1.merge(hash2))
		end
	end

	return result
end

def process(data, columns, parent)

	keys = data.keys
	common_part = keys & columns
	lower_level = {}

	if !columns.empty?

		found = false
		array = []
		data.each do |key, value|
			
			if value.is_a?(Hash)
				found = true
				columns_copy = columns.dup

				columns_copy.delete(parent) if columns.include?(parent)
				#puts "Going down to: #{key}"
				res=process(value, columns_copy, key)
				#puts "result: #{result}"
				#array.push(res) if !res.empty?
				lower_level = res
				if parent !='' && columns.include?(parent)
						
						if res.is_a?(Array)
							res.each do |r|
								r[parent]=key
							end
						else
							res[parent]=key
						end
				end
				
				if res.is_a?(Array) && array.empty? && !res.empty?
					array=res
				elsif res.is_a?(Array) && !array.empty? && !res.empty?
					# Merging
					
					m = merge(array, res)
					array = m
				else
					array.push(res) if !res.empty?
				end
			end
		end
		# Check if many arrays
		
		lower_level = array if array.length > 1
	end
	
	tepmoral_res = Hash.new
	tepmoral_res = lower_level if !lower_level.empty?
	common_part.each do |column|
		parameter = data[column]
		if parameter.is_a?(Hash)
				
		else
			if tepmoral_res.is_a?(Array)
				tepmoral_res.each do |re|
					re[column]=parameter
				end
			else
				tepmoral_res[column]=parameter
			end
			columns.delete(column)
		end
	end

	return lower_level if !lower_level.empty?
	return tepmoral_res
end

level = 0

def print_result(array)
	array.each do |arr|
		
	end	
end


puts ""
puts ""

puts "RES"

data.each do |key, value|
	value.each do |entity, entity_data|
		hash = Hash.new
		hash['sc_entity']={entity => entity_data}
		res = process(hash, columns.dup, "")
		if res.is_a?(Array)
			res.each do |r|
				p r
			end
		else
			p res
		end
	end
end

