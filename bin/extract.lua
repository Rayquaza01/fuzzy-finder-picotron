-- extract the p64.png into the src directory
local err = cp("../fzf.p64.png/", "../src")
if err then
	print(err)
end
