#! /bin/bash 

#oil, but bash. 
#temp dir

dotf=0;
filef=0;
#flags! here we go!
while getopts "fdh" flag; do
	case $flag in 
		f)
			filef=1;;
		d)
			dotf=1;;
		h)
			echo "FOIL : oil wannabe, but in bash"
			echo "written by Utkarsh out of spite"
			echo 
			echo "Usage:"
			echo "foil       Opens the filesystem. By default, ignores subfolders and dotfiles"
			echo "foil -d    Show dotfiles"
			echo "foil -f    Show subfolders"
			exit ;; 

	esac
done

tdir=$(mktemp -d -t foil_XXXXXX) #tempdir maker is pretty goated, makes a nice new dir without collisions.
#-d is for directory creation, -t is to allow the template. X's are for random numbers. 

#make sure ctrl + c erases the tempdir
trap 'rm -rf "$tdir"' EXIT 

cur=$(realpath "$PWD")
#go in the directory, make the snapshot files 
#adding exit as a safeguard in case cd fails 
cd "$tdir" || exit 
touch filebef.txt
touch fileaft.txt
cd "$cur" || exit 

#find and list the toplevel files. 

#find help:
#-f is for files, -printf is a find specific. %P prints the name relative to the current directory , takes out redundant folders. 
#=o acts as an OR operator, allows us to link commands basically 
# file descriptor 2 is the stderr line, redirected to dev/null blackghole
#
if [[ $dotf == 0  ]] && [[ $filef == 1 ]]; then 
	 
	# \ allows us to have multi line commands. 
	# However, absolutely makesure to remove all spaces.
	# Generaly, the editor does highlight the backslash differently when its used to have multiline

	find . -path "./$(basename "$tdir")" -prune \
		-o -wholename "./.*" -prune \
		-o -type f -printf "%P\n" 2>/dev/null > "$tdir/filebef.txt"

elif [[ $dotf == 1 ]] && [[ $filef == 1 ]];then
	find . -path "./$(basename "$tdir")" -prune \
		-o -type f -printf "%P\n" >"$tdir/filebef.txt" 2>/dev/null

elif [[ $dotf == 0 ]] && [[ $filef == 0 ]]; then 

	find . -maxdepth 1 -path "./$(basename "$tdir")" -prune \
		-o -wholename "./.*" -prune \
		-o -type f -printf "%P\n" 2>/dev/null > "$tdir/filebef.txt"

elif [[ $dotf == 1 ]] && [[ $filef == 0 ]]; then
	
	find . -maxdepth 1 -path "./$(basename "$tdir")" -prune \
		-o -type f -printf "%P\n" >"$tdir/filebef.txt" 2>/dev/null

fi
#listen man. inline ifs break so much shit. i'll do them later. this works. don't judge me. 
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
		# The m flag se nonexistent paths are also well treated 

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
				echo " $d_count Files Deleted"
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
	lepath=$(realpath -m "$line")
	#helpful tip : if you did end up not referncig the value of lepath,
	#it would just treat it as a string. 
	if [[ "$lepath" != "$cur/"* ]]; then 
		echo "$line"
	fi 
done <<< "$newfiles"
while IFS= read -r line; do
	lepath=$(realpath -m "$line")
	if [[ "$lepath" != "$cur/"* ]]; then 
		echo "$line"
	fi 
done <<< "$delfiles"
fi
#need not delete the temp rep, we've set a trap 
