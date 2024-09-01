--[[pod_format="raw",created="2024-08-20 16:28:55",modified="2024-08-21 19:21:20",revision=2170]]
-- https://github.com/TheAlgorithms/Lua/blob/main/src/sorting/mergesort.lua
-- MIT License

-- list - list to be sorted in-place
-- less_than - function(a, b) -> truthy value if a < b
function sort(list, less_than)
	less_than = less_than or function(a, b)
		return a < b
	end
	-- Merges two sorted lists; elements of a come before those of b
	local function merge(result, list_1, list_2)
		local result_index = 1
		local index_1 = 1
		local index_2 = 1
		while index_1 <= #list_1 and index_2 <= #list_2 do
			-- Compare "head" element, insert "winner"
			if less_than(list_2[index_2], list_1[index_1]) then
				result[result_index] = list_2[index_2]
				index_2 = index_2 + 1
			else
				result[result_index] = list_1[index_1]
				index_1 = index_1 + 1
			end
			result_index = result_index + 1
		end
		-- Add remaining elements of either list or other_list
		for offset = 0, #list_1 - index_1 do
			result[result_index + offset] = list_1[index_1 + offset]
		end
		for offset = 0, #list_2 - index_2 do
			result[result_index + offset] = list_2[index_2 + offset]
		end
	end

	local function mergesort(list_to_sort, lower_index, upper_index)
		if lower_index == upper_index then
			list_to_sort[1] = list[lower_index]
		end
		if lower_index >= upper_index then
			return
		end
		local middle_index = math.floor((upper_index + lower_index) / 2)

		local left = {}
		mergesort(left, lower_index, middle_index)
		local right = {}
		mergesort(right, middle_index + 1, upper_index)

		merge(list_to_sort, left, right)
	end
	mergesort(list, 1, #list)
end