#!/bin/bash

#oil, but bash. 
#temp dir
#

tdir=$(mktemp -d -t foil_XXXXXX) #tempdir maker is pretty goated, makes a nice new dir without collisions. -d is for directory creation, -t is to allow the template. X's are for random numbers. 

#make sure ctrl + c erases the tempdir
trap 'rm -rf "$tdir"' EXIT 
cur=$(realpath "$PWD")
#go in the directory, make the snapshot files 
cd "$tdir"
touch filebef.txt
touch fileaft.txt
cd "$cur"

#find and list the toplevel files. -f is for files, -printf is a find specific. Redir to filebef. 
find . -path "./$(basename "$tdir")" -prune -o -type f ! -name ".*" -printf "%P\n" 2>/dev/null > "$tdir"/filebef.txt

#-o acts as an OR. 
#file descriptor 2 is the stderr line, which is redirected to the blackhole 
#prune the ones that are in the tdir path.
#ignore the ones that are in the form .
cp "$tdir"/filebef.txt "$tdir"/fileaft.txt

${EDITOR:-vim} "$tdir"/fileaft.txt
#the user does their shit 


c_count=0;
d_count=0;
deltoggle=0;
#CREATE FILES 
#comm returns 3 columns : 
#1: only in f1
#2: only in f2
#3: common to both
#get only the second column, i.e the one which has fileaft's uniques files 
newfiles=$(comm -13 <(sort "$tdir"/filebef.txt) <(sort "$tdir"/fileaft.txt) | sed '/^\s*$/d') #after comparision, any space or empty lien is stream edited 
if [[ -z "$newfiles" ]]; then
	echo 
else
	#Internal Field Separater is basically a tokenizer? i think? 
	while IFS= read -r line; do #ifs splits spaces by def
			    #r makes it do that only on lines
		#lmao, user could just fuck the system by using abs path outside base.
		#prevent that from happening:
		lepath=$(realpath -m "$line") 
		#mflag se nonexistent paths are also well treated 

		#the user could also just manually overwrite these files, so gotta skip this too
		if [[ "$lepath" != "$cur/"* || "$lepath" == "$tdir/"* ]]; then 
			((deltoggle++))
			continue
		else 
			echo "CREATE $line"
		fi 
		#earlier, i just killed the program with unsafe paths, but 
		#maybe skipping and then informing user of them is better.

	done <<< "$newfiles"
	
	
	read -rp "Proceed? (y/n):" ans
		case $ans in #insane moment - | acts as a seperator here, not a pipe.
			#bash just does that huh 
			y|Y)
				while IFS= read -r line; do
					lepath=$(realpath -m "$line") 
					if [[ "$lepath" != "$cur/"* || "$lepath" == "$tdir/"* ]]; then 
						continue
					else
						mkdir -p "$(dirname "$line")"  #default is . 
						touch "$line" #single prevents expansion. 
						((c_count++)) #airthmetic evaluation operator
					fi 
				done <<< "$newfiles"
				echo "$c_count Files created"
				;; #case end is double semic
			n|N) 
				echo "Creation cancelled"
				;;
			*) 
				echo "Invalid Option"
				;;
		esac
fi 

delfiles=$(comm -23 <(sort "$tdir"/filebef.txt) <(sort "$tdir"/fileaft.txt) | sed '/^\s*$/d') #after comparision, any space or empty lien is stream edited 
if [[ -z "$delfiles" ]]; then
	echo 
else
	while IFS= read -r line; do 
		lepath=$(realpath -m "$line") 
		if [[ "$lepath" != "$cur/"* || "$lepath" == "$tdir/"* ]]; then 
			continue
		else 
			echo "DELETE $line"
		fi 

	done <<< "$delfiles"
	
	read -rp "Proceed? (y/n):" ans
		case $ans in 
			y|Y)
				while IFS= read -r line; do
					lepath=$(realpath -m "$line") 
					if [[ "$lepath" != "$cur/"* || "$lepath" == "$tdir/"* ]]; then 
						continue
					else
						rm -rf "$line"
						((d_count++))
					fi 
				done <<< "$delfiles"
				echo " "$d_count" Files Deleted"
				;;
			n|N) 
				echo "Deletion cancelled"
				;;
			*) 
				echo "Invalid Option"
				;;
		esac
fi 


#Final print for the invalid files 
if [[ -z "$deltoggle" ]];then
echo "The following files were not modified : FILE PATH NOT IN CURRENT DIRECTORY"
while IFS= read -r line; do 
	lepath= $(realpath -m "$line")
	if [[ lepath != "$cur/"* ]]; then 
		echo "$line"
	fi 
done <<< "$newfiles"
while IFS= read -r line; do
	lepath= $(realpath -m "$line")
	if [[ lepath != "$cur/"* ]]; then 
		echo "$line"
	fi 
done <<< "$delfiles"
fi
#need not delete the temp rep, we've set a trap 
