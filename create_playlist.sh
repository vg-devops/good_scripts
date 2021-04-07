#!/bin/bash

declare -a dir_array
declare -a sorted_dir_array
declare -a file_array
declare -a sorted_file_array

file_ext="*.mp4"
base_path=$(pwd)
quotes='"'
playlist_name="playlist.m3u"
add_file_number=true
remove_insert="remove_non-essential-domain\.com"  # note: use escape '\' for . characters, the search is case-insensitive


while getopts n:e:h flag
do
    case "${flag}" in
        e) file_ext="${OPTARG}"; echo -e "\e[36mextension added as argument \e[0m";;
		n) playlist_name="${OPTARG}"".m3u"; echo -e "\e[36mplaylist name added as argument \e[0m";;
		h) echo -e "please use with double quotes, like: \e[93m -e "$quotes"*.ext"$quotes"\e[0m for 1st script argument and with \e[93m -n "$quotes"playlist_file_name_without_extension"$quotes"\e[0m for 2nd argument"; exit 0;;
        *) echo -e "incorrect argument, exiting, please use with double quotes, like: \e[93m -e "$quotes"*.ext"$quotes"\e[0m for script argument"; exit 1;;
    esac
done

echo "Renaming file names first, i.e. removing '[]' brackets, 'REMOVE INSERT', also extra dashes and spaces, replace % with 'pc'"
find . -type f -iname "${file_ext}" | while IFS= read -r line; do mv "$line" "$(printf %s "$line" | sed -re 's/(\[|\])//g' | tr -s '-' | sed "s|$remove_insert||I" | tr -s ' ' | tr -s '-' | sed "s|- -||I" | sed 's/%/pc/g')"; done;
find . -type d -iname "*" | while IFS= read -r line; do mv "$line" "$(printf %s "$line" | sed 's/%/pc/g')"; done;

echo "the list will be created for all files with the following file 'extensions:' "
printf "${file_ext}" ## USE DOUBLE QUOTES TO PREVENT EXPANSION OF LOCAL FILE NAMES FROM WITHIN * (Star)
printf "\n"

echo "play list will be saved as $playlist_name within the execution folder"

IFS=''; while read -r -d $'\0'; do
	REMOVED_DOTSLASH="${REPLY#./}"  ## REMOVING ./ AT THE FRONT OF DIRECTORY NAME, NOTE "REPLY" IS REGISTERED VARIABLE
	ADDED_NEWLN="$REMOVED_DOTSLASH\n"  ## ADDING NEW LINE CHARACTER AT THE END OF EACH DIRECTORY NAME
	dir_array+=($ADDED_NEWLN)
done < <(find . -maxdepth 1 ! -path . -type d -print0)

IFS=$'\n'

# printf "first element	="${dir_array[0]}
# printf "second element	="${dir_array[1]}
# printf "third element	="${dir_array[2]}	

N_ROOT_DIRS=${#dir_array[@]}
N_FILES_FOUND=0

echo "----------------------------------------------------------------------------------------------------------"
echo "----------------------------------------------------------------------------------------------------------"
echo "----------------------------------------------------------------------------------------------------------"
i_file=0

if [[ "$N_ROOT_DIRS" -gt 0 ]] # no subdirectories
	then

	readarray -td '' sorted_dir_array < <(printf '%s\0' "${dir_array[@]}" | sort -z -V)
	# Alternative solution for the same functionality is prvided below, removes all front spaces
	# readarray -t sorted_dir_array < <(for a in "${dir_array[@]}"; do printf "$a"; done | sed '/^[[:space:]]*$/d' | sort)
	# echo "PRINTING SORTED DIRECTORY ARRAY"
	# printf "${sorted_dir_array[*]}"
	
    dir_array=()
	i=0
	echo "SUBFOLDERS EXIST WITHIN EXECUTION FOLDER, WILL CONTINUE SEARCHING WITHIN SUBFOLDERS"
	echo "#EXTM3U" > "$playlist_name"

	for dir_line in ${sorted_dir_array[@]}
		do
		i=$(($i+1))
		full_dir_line=$(pwd)"/"$dir_line
		full_dir_line="${full_dir_line::-2}"
		file_array=()
		sorted_file_array=()
		IFS=''; while read -r -d $'\0' 
			do
			REMOVED_DOTSLASH="${REPLY#./}"  ## REMOVING ./ AT THE FRONT OF DIRECTORY NAME, NOTE "REPLY" IS REGISTERED VARIABLE
			ADDED_NEWLN="$REMOVED_DOTSLASH\n"  ## ADDING NEW LINE CHARACTER AT THE END OF EACH DIRECTORY NAME
			file_array+=($ADDED_NEWLN)
			N_FILES_FOUND=$(($N_FILES_FOUND+1))
			printf '%s\n' "["${i}"] Checking files in directory="$full_dir_line
			done < <(find $full_dir_line -maxdepth 1 -type f -name "$file_ext" -print0)

		readarray -td '' sorted_file_array < <(printf '%s\0' "${file_array[@]}" | sort -z -V)

		for file_line in ${sorted_file_array[@]}
			do
			printf '%s\n' "$file_line""\n"
			printf '%s\n' "$base_path""\n"
			shortened_path=$(printf '%s' "$file_line" | sed -e "s|^$base_path||" | sed 's/\\n$//')
			shortened_path="${shortened_path:1}"
			# more_shortened_path=$(printf '%s\n' "$shortened_path" | sed -e 's/^[[:space:]]*//' | sed -e 's/^[0-9]*//g' | sed -e 's/^[[:space:]]*//' | sed -e 's/^[0-9]*//g' | sed -e 's/^[[:space:]]*//')
			# more_shortened_path=$(printf '%s\n' "$more_shortened_path" | sed -e 's/^-*//' | sed -e 's/^[0-9]*//g' | sed -e 's/^[[:space:]]*//' | sed -e 's/^-*//' | sed -e 's/^[[:space:]]*//' )
			more_shortened_path=$(printf '%s\n' "$shortened_path" | sed -e 's/^[[:space:]0-9-]*//') # removes spaces, numbers and dashes before the path
			more_shortened_path=$(echo "${more_shortened_path%.*}" | tr -d '\n' | tr -d ','|  sed -e 's/^\.//' | sed -e 's/^[[:space:]]*//' |  sed 's/-/\xE2\x80\x94/g') #latter replaces with long dashes
			i_file=$(($i_file+1))
			if [ "$add_file_number" = true ]; then more_shortened_path="$i_file"".""$more_shortened_path"; fi
			# extracted_file_name=$(printf $file_line | sed "s|.*\/||" | sed 's/-/\xE2\x80\x94/g')
			# extracted_file_name=$(printf "${extracted_file_name%.*}")
			echo "#EXTINF:-1,""$more_shortened_path" >> "$playlist_name"
			echo $shortened_path >> "$playlist_name"
			done
		done

	if [[ "$N_FILES_FOUND" -le 0 ]] 
		then 
		echo "No $file_ext files found in subfolders, exiting"
		exit 0
		fi
	
	else
    dir_array=()
	i=0
	echo "#EXTM3U" > "$playlist_name"
	printf "assumed that all ""$file_ext"" files are available in local folder\n"
	full_dir_line=$(pwd)"/"
	#full_dir_line="${full_dir_line::-2}"
	file_array=()
	sorted_file_array=()
	IFS=''; while read -r -d $'\0' 
		do
		REMOVED_DOTSLASH="${REPLY#./}"  ## REMOVING ./ AT THE FRONT OF DIRECTORY NAME, NOTE "REPLY" IS REGISTERED VARIABLE
		ADDED_NEWLN="$REMOVED_DOTSLASH\n"  ## ADDING NEW LINE CHARACTER AT THE END OF EACH DIRECTORY NAME
		file_array+=($ADDED_NEWLN)
		printf '%s\n' "Checking files in execution directory="$full_dir_line"\n"
		done < <(find $full_dir_line -maxdepth 1 -type f -name "$file_ext" -print0)
	
	N_FILES_FOUND=${#file_array[@]}
	if [[ "$N_FILES_FOUND" -le 0 ]] 
		then 
		echo "No $file_ext files found in subfolders (depth of 1) or in the execution folder, exiting"
		exit 0
		fi
	readarray -td '' sorted_file_array < <(printf '%s\0' "${file_array[@]}" | sort -z -V)

	for file_line in ${sorted_file_array[@]}
		do
		printf '%s\n' "$file_line"
		printf '%s\n' "$base_path""\n"
		shortened_path=$(printf '%s' $file_line | sed -e "s|^$base_path||" | sed 's/\\n$//')
		shortened_path="${shortened_path:1}"
		extracted_file_name=$(printf '%s\n' "$file_line" | sed "s|.*\/||")
		extracted_file_name=$(printf '%s\n' "${extracted_file_name%.*}")
		extracted_file_name=$(printf '%s\n' "$extracted_file_name" | sed -e 's/^[[:space:]0-9-]*//')
		extracted_file_name=$(printf '%s\n' "$extracted_file_name" | tr -d ',' | sed -e 's/^\.*//' | sed -e 's/^[[:space:]]*//' | sed -e 's/^-*//' | sed -e 's/^[[:space:]]*//' | sed -e 's/^\.//' | sed 's/-/\xE2\x80\x94/g')
		i_file=$(($i_file+1))
		if [ "$add_file_number" = true ]; then extracted_file_name="$i_file"".""$extracted_file_name"; fi
		echo "#EXTINF:-1,""$extracted_file_name" >> "$playlist_name"
		echo $shortened_path >> "$playlist_name"
		done
	
	fi
