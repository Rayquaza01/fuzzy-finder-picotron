argv = env().argv
path = env().path or "/"
if argv[1] then
	path = argv[1]
end

create_process("/appdata/system/util/fzf.p64",
	{
		argv = {
			"--folders",
			"--no-files",
			"--clipboard",
			path
		}
	}
)
