argv = env().argv
if #argv < 1 or argv[1] == "--help" then
	print("Usage: igrep [file]")
	print("Searches a file interactively using fuzzy finder")
	exit()
end

file = argv[1]
if fstat(file) != "file" then
	print("Argument must be a file!")
	exit()
end

create_process("/appdata/system/util/fzf.p64",
	{
		argv = {
			"--list=" .. file,
			"--index",
			"--clipboard",
			"--copy-index"
		},
		path = env().path
	}
)
