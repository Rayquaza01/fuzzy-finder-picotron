--[[pod_format="raw",created="2024-10-21 12:24:17",modified="2024-10-21 12:25:53",revision=5]]
-- build script
-- please run from inside picotron
local err = cp("../src", "../fzf.p64.png")
if err then
	print(err)
end