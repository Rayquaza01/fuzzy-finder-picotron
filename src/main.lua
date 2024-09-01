--[[pod_format="raw",created="2024-03-15 13:58:36",modified="2024-08-21 19:30:16",revision=3142]]
-- fuzzy finder v1.0
-- by Arnaught

include("fzy.lua")
include("pad.lua")
include("list_files.lua")

include("default_settings.lua")

cd(env().path)
argv = env().argv

function _init()
	printh("-- fuzzy finder start --")

	window({
		width = 256, height = 128,
		title = "Fuzzy Finder"
	})

	ignore_file = default_ignore_file

	list_mode = "FILESYSTEM"

	if not fstat("/appdata/fuzzy_finder") then
		mkdir("/appdata/fuzzy_finder")
	end

	if not fstat(default_settings_file) then
		store(default_settings_file, default_settings)
	end

	settings = default_settings
	if fstat(default_settings_file) == "file" then
		settings = fetch(default_settings_file)
	end

	-- process commandline arguments
	-- - in lua means * in regex.
	positional_args = {}
	for i = 1, #argv, 1 do
		if not argv[i]:find("^%-%-") then
			table.insert(positional_args, argv[i])
		else
			if argv[i]:find("%-files") then
				settings.show_files = not argv[i]:find("%-no%-")
			end

			if argv[i]:find("%-folders") then
				settings.show_folders = not argv[i]:find("%-no%-")
			end

			if argv[i]:find("%-execute%-lua") then
				settings.execute_lua = not argv[i]:find("%-no%-")
			end

			if argv[i]:find("%-execute%-p64") then
				settings.execute_p64 = not argv[i]:find("%-no%-")
			end

			if argv[i]:find("%-clipboard") then
				settings.clipboard = not argv[i]:find("%-no%-")
			end

			if argv[i]:find("%-index") then
				settings.show_index = not argv[i]:find("%-no%-")
			end

			if argv[i]:find("%-copy%-index") then
				settings.copy_index = not argv[i]:find("%-no%-")
			end

			if argv[i]:find("%-ignore") then
				if argv[i]:find("=") then
                    --- @type string[]
					local l = split(argv[i], "=")

					if fstat(l[2]) == "file" then
						ignore_file = l[2]
					end
				else
					settings.ignore = not argv[i]:find("%-no%-")
				end
			end

			-- if argument is --list=file
			if argv[i]:find("%-%-list%=") then
                --- @type string[]
				local l = split(argv[i], "=", false)
                local list_path = l[2]
				-- check if param is a file
				-- if it is, set list mode to file mode
				-- and open the file
				-- also enable clipboard mode
				if fstat(list_path) == "file" then
					list_mode = "FILE"
					settings.clipboard = true
                    local list = fetch(list_path)

                    --- @cast list string
					file_list = split(list, "\n")
				end
			end
		end
	end

	if not fstat(default_ignore_file) then
		store(default_ignore_file, table.concat(default_ignore_list, "\n"))
	end

	-- load monospace font into second font slot
	-- use print("\014") to use this font
    fetch("/system/fonts/lil_mono.font"):poke(0x5600)

	selected = 1

	-- create a text editor for the search box
	g = create_gui()
	ce = g:attach_text_editor({
		x = 0, y = 0,
		width = get_display():width(), height = 14,
		bgcol = 24, fgcol = 7,
		width_rel = 1.0
	})

	ce:set_text("")

	-- the current string used for filtering the list
	filter_string = nil
	-- the results of the filtering
	filter = {}

	-- set path to the cwd or / by default
	path = env().path or "/"
	-- if there's a positional argument, set the path to that
	if positional_args[1] then
		path = positional_args[1]
	end

	-- only traverse filesystem if index is enabled
	if list_mode == "FILESYSTEM" then
		ignore_list = default_ignore_list
		if settings.ignore and fstat(ignore_file) == "file" then
            local ignore_list = fetch(ignore_file)
            --- @cast ignore_list string
			ignore_list = split(ignore_list, "\n")
		end

		file_list = list_files(path, ignore_list)

		-- if folders are shown,
		-- include top level folder in output
		if settings.show_folders then
			table.insert(file_list, 1, path)
		end

		-- subprocess to filter the list
		-- nil when not running
		filter_routine = nil
	end

	index_length = 0
	if settings.show_index then
		index_length = #tostr(#file_list) + 1
	end

	scroll_offset = 0

	-- get the total number of entries that can be displayed onscreen
	-- update it when the window is resized
	max_display = flr((get_display():height() - 16 - 7) / 10)
	on_event("resize", function()
		max_display = flr((get_display():height() - 16 - 7) / 10)
	end)
end

function _update()
	ce:set_keyboard_focus(true)
	g:update_all()

	-- if there are multiple lines, then user pressed enter
	if #ce:get_text() > 1 then
		-- move cursor to end of line in case user selects invalid item
		ce:set_cursor(#ce:get_text()[1] + 1, 1)

		-- continue if there is at least one search result
		if #filter > 0 then
			-- selected is indexing the search filter, which gives us
			-- the index for the file list
			local selected_index = filter[selected][1]
			local selected_path = file_list[selected_index]
            --- @cast selected_path string

			-- will file be executed
			local exe = false

			-- shift key toggles clipboard
			-- if clipboard is enabled, selecting an item will copy it to the clipboard
			-- if disabled, selecting it will open it
			-- shift inverts
			if settings.clipboard != key("shift") then
				if settings.copy_index then
					set_clipboard(tostr(selected_index))
				else
					set_clipboard(selected_path)
				end
			else
				-- similar to clipboard
				-- if execute p64 is enabled, selecting it will run it
				-- if disabled, selecting it will open it
				-- ctrl inverts
				if selected_path:find("%.p64$") or selected_path:find("%.p64%.png$") then
					exe = settings.execute_p64 != key("ctrl")
				end

				-- same as execute p64
				if selected_path:find("%.lua$") then
					exe = settings.execute_lua != key("ctrl")
				end

				if exe then
					create_process(selected_path)
				else
					create_process("/system/util/open.lua", { argv = { selected_path } })
				end
			end

			exit()
		end
	end

	-- get first line of search text
	local search_text = ce:get_text()[1] or ""
	ce:set_text(search_text)

	-- if current filter string is different than search text
	-- start filtering process
	if filter_string != search_text then
		filter_string = search_text

		filter_routine = coroutine.create(fzy.filter)
		-- search file list for the search text
		-- ignore whitespace in search
		local err, res = coresume(filter_routine, search_text:gsub("%s+", ""), file_list, false)

		if res != nil then
			filter = res
		end
	end

	-- if filter routine exists, and coroutine is not dead, continue it
	-- otherwise remove the routine
	if filter_routine and coroutine.status(filter_routine) != "dead" then
		local err, res = coresume(filter_routine)

		if res != nil then
			filter = res
		end
	else
		filter_routine = nil
	end

	-- if up or ctrl+k or ctrl+p
	if keyp("up") or key("ctrl") and (keyp("k") or keyp("p")) then
		selected -= 1
	end

	-- if down or ctrl+j or ctrl+n
	if keyp("down") or key("ctrl") and (keyp("j") or keyp("n")) then
		selected += 1
	end

	-- quit on ctrl+q
	if key("ctrl") and key("q") then
		exit()
	end

	-- keep selected inside of the range
	selected = mid(1, selected, #filter)
	if selected > (max_display + scroll_offset - 2) then
		scroll_offset += 1
	end

	if selected < (1 + scroll_offset) then
		scroll_offset -= 1
	end
end

function _draw()
	cls(1)
	-- print total number of files and number of filtered files in bottom of window
	print(string.format("Total: \fs%d\f7, Filtered: \fs%d\f7", #file_list, #filter), 0, get_display():height() - 8)
	-- draw text editor
	g:draw_all()

	-- if search results exist, print selection arrow and background box
	if #filter > 0 then
		rectfill(0, 6 + (selected - scroll_offset) * 10, get_display():width(), 13 + (selected- scroll_offset) * 10, 2)
		print(">", 0, 6 + (selected - scroll_offset) * 10, 7)
	end

	-- print search results on screen
	for filter_i = 1 + scroll_offset, min(max_display + scroll_offset, #filter), 1 do
		local line_i = filter_i - scroll_offset
		local i, p = unpack(filter[filter_i])

		local entry = file_list[i]:gsub("\t", " ")
		if settings.show_index then
			entry = right_pad(tostr(i), index_length) .. entry
		end

		-- print in monospace
		print("\014" .. entry, 8, 6 + line_i * 10, 7)
		-- reprint matching positions in green
		for pos in all(p) do
			print(
				"\014" .. entry:sub(pos + index_length, pos + index_length),
				8 + (index_length * 5) + (pos - 1) * 5,
				6 + line_i * 10,
				11
			)
		end
	end

	-- if filter routine exists and is not dead, display an hour glass
	if filter_routine and coroutine.status(filter_routine) != "dead" then
		spr(1, get_display():width() - 16, 0)
	end
end
