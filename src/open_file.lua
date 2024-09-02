--[[pod_format="raw"]]
function open_file(path, index, settings)
	if path:find("%.loc$") and settings.follow_loc then
		local loc_path = fetch(path).location
		return open_file(loc_path, index, settings)
	end

	-- will file be executed
	local exe = false

	-- shift key toggles clipboard
	-- if clipboard is enabled, selecting an item will copy it to the clipboard
	-- if disabled, selecting it will open it
	-- shift inverts
	if settings.clipboard != key("shift") then
		if settings.copy_index then
			set_clipboard(tostr(index))
		else
			set_clipboard(path)
		end
	else
		-- similar to clipboard
		-- if execute p64 is enabled, selecting it will run it
		-- if disabled, selecting it will open it
		-- ctrl inverts
		if path:find("%.p64$") or path:find("%.p64%.png$") then
			exe = settings.execute_p64 != key("ctrl")
		end

		-- same as execute p64
		if path:find("%.lua$") then
			exe = settings.execute_lua != key("ctrl")
		end

		if exe then
			create_process(path)
		else
			create_process("/system/util/open.lua", { argv = { path } })
		end
	end

	exit()
end
