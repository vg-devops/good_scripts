#!/bin/bash

git status > /dev/null 2>&1 || echo "not running within 'git' directory... exiting.. bye bye" || exit 1

min_commits=10000
echo "this is 'git' directory, continuing..."
echo "current depths of search is $min_commits commits"
echo input your search string
read -p $'\e[96myour search here: \e[0m' var_search_string

if [ ${#var_search_string} -le 3 ]
then
    echo "search string is too short, exiting..."
    exit 0
fi

# later on, this will be updated to reflect more commits

declare -a commits_ar
declare -a commit_authors_ar

#IFS=$'\n'; 
commits_ar=$(git log | grep "^commit" | head -${min_commits} | cut -d' ' -f2 | tr "\n" " ")
commit_authors_ar=$(git log | grep "^commit" -A1 | grep "Author" | head -${min_commits} | tr " " "_" | tr "\n" " ")
n_checked=0
n=1 # start comparing of commits 0 to 1, 1 to 2, 2 to 3 and so on
found=false

for commit in "${commits_ar[@]}"
do
	#echo "commit[$((n-1))]=$commit"
	if [ "$n" -gt "$min_commits" ]; then break; fi
	strings=$(git diff "$commit..${commits_ar[n]}" | grep "^+" | grep "$var_search_string")
	if [ "${#strings}" -gt 3 ]
	then
		any_match=true
	else
		any_match=false
	fi	
	
	if "$any_match"
	then
		found=true
		echo -e "\e[91mfound commit No:$((n-1)) that caused changes: $commit"
		commit_author=$(echo ${commit_authors_ar[$((n-1))]} | tr "_" " ")
		echo -e "\e[93mmade by $commit_author"
		echo -e "\e[93mpushed changes are as follows:"
		echo -e "\e[1;94;49m$strings"
		echo -e "\e[0m"
	fi

	
	let n++
let n_checked++
done

if [[ $found == false ]]
then
	echo -e "no patterns were added within last\e[91m $n_checked\e[0m commits for search string: \e[91m$var_search_string"
	echo -e "\e[0m"
else
	echo -e "checked\e[91m $n_checked\e[0m commits for search string: \e[91m$var_search_string"
        echo -e "\e[0m"
fi





