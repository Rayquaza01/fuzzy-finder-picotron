# fuzzy-finder-picotron
A fuzzy finder for Picotron

## Usage

* Open fuzzy finder and search for a file
* Navigate the list with `Ctrl+n` and `Ctrl+p`, `Ctrl+j` and `Ctrl+k`, or `Up` and `Down`
* Select an item with `Enter`
* Copy an item to clipboard with `Shift+Enter`
* If selected item is executable (`.p64`), it will run
 * Press `Ctrl+Enter` to browse to it instead
* Selected files and folders will be opened in their default programs

## Configuration

Fuzzy Finder can be configured via a pod file stored at `/appdata/fuzzy-finder/settings.pod`, or via command line arguments.

An option can be enabled by passing the option `--<option-name>`, and disabled by passing `--no-<option-name>`

* `--execute-lua` - [off] execute `.lua` files instead of editing them
* `--execute-p64` - [on] execute `.p64` and `.p64.png` instead of browsing to them
* `--show-files` - [on] show files in list
* `--show-folders` - [on] show folders in list
* `--clipboard` - [off] copy the selected line to the clipboard instead of opening
* `--show-index` - [off] show index of items in list
* `--copy-index` - [off] copy the index instead of the line
* `--ignore` - [on] ignore patterns in the ignore file (`/appdata/fuzzy-finder/ignore.txt`)
* `--follow-loc` - [on] follow `.loc` files to their destination before opening

Some options can also have additional arguments

* `--ignore=[file]` - set an ignore file and ignore patterns in the ignore file
* `--list=[file]` - set a list file to use instead of the filesystem

## Use Cases

Fuzzy Finder can be used in a variety of different ways.

### Keystroke Launcher

The default configuration of fuzzy finder makes it work well as a keystroke launcher. You can find and open files and folders, as well as run cartridges.

### Interactive Grep

`fzf --list=[file] --index --clipboard --copy-index` will list the contents of a file and allow you to search through that file. The line numbers are shown, and selecting a line will copy its line number. You can jump to a line number within a file with `Ctrl+l` in Picotron's editor.

A wrapper script for this is available in `util/igrep.lua`.

### Path Jumping

`fzf --folders --no-files --clipboard` will list only directories. Selecting a folder will copy it's path to the clipboard. You can then paste the path to quickly `cd` into it.

A wrapper script for this is available in `util/z.lua`.

## Acknowledgements

* [mergesort.lua from TheAlgorithms/Lua](https://github.com/TheAlgorithms/Lua/blob/main/src/sorting/mergesort.lua) - MIT License
* [swarn/fzy-lua](https://github.com/swarn/fzy-lua) - MIT License

