--[[pod_format="raw",created="2024-08-21 13:40:02",modified="2024-08-21 15:18:33",revision=209]]
function list_files(path, ignore_list)
	file_list = {}
	to_process = { path }
	while #to_process > 0 do
		local top = table.remove(to_process)

		-- if top of list does not end with a /
		-- add the slash to make path joining easier
		if not top:find("/$") then
			top = top .. "/"
		end

		local files = ls(top)
		for i = 1, #files, 1 do
			local f = top .. files[i]
			local f_type = fstat(f)

			-- check if file passes all ignore rules
			local include = true
			if #ignore_list > 0 then
				for rule in all(ignore_list) do
					include = include and not f:find(rule)
				end
			end

			if include then
				-- if folder, then add to to_process table to traverse it
				if f_type == "folder" then
					table.insert(to_process, f .. "/")
				end

				-- if folder and folders are enabled, add to file list
				if f_type == "folder" and settings.show_folders then
					table.insert(file_list, f)
				end

				if f_type == "file" and settings.show_files then
					table.insert(file_list, f)
				end
			end
		end
	end

	return file_list
end
