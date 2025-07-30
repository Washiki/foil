# Foil : a simple bash file manager

A simple file manager for creating and deleting files.

Written in `bash`. 
Emulates the simpler aspects of `oil.lua`.

## Prerequisites
- Needs a `bash` or `posix` compliant terminal 

#### Setup
In your `.bashrc ` file, add : 
```
alias foil="<your-directory>/foil.sh"
```
where `your-directory` is the directory where foil.sh has been downloaded.

Now, to make it runnable as an executable, in your shell, run:
```
chmod +x <your-directory>/foil.sh
```
This gives executable permissions to `foil`, which can now be called as a command from wherever in the system.


## Usage 

In your bash terminal, run:
```
foil
```
By default , this will open in the set `$Editor` , or if not present, in vim.

For ***creating a file***, simply type its name along with the extension. 

For ***deleting a file***, simply delete the line it is on. 

ONLY ONE FILE PER LINE IS SUPPORTED. 

## Example 
Let the initial directory `dir` be as follows: 

```
dir
	├── filea.txt
	├── fileb.txt
	└── somefolder
		└── filec.txt
```

Running `foil` in this directory produces the following in your editor:

```
filea.txt
fileb.txt
somefolder/filec.txt
```

To **remove** a file (say filec.txt and filea.txt), just remove the lines they are on , i.e delete 
` filea.txt` and `somefolder/filec.txt`

To **add** a file ( say filex.txt in in a subdirectory mastikhor) , just add the line `mastikhor/filex.txt`

This leads to:

```
dir 
	├── fileb.txt
	└── mastikhor
		└── filextxt
```

View in the Editor:

```
fileb.txt
xyz/filex.txt
```
