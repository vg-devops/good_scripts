#!/bin/bash

git status > /dev/null 2>&1 || echo "not running within 'git' directory... exiting.. bye bye" || exit 1

echo "this is 'git' directory, continuing..."
echo current depths of search is 100 commits
echo input your commit author name
read -p $'\e[96mauthor search here: \e[0m' var_search_string

if [ ${#var_search_string} -le 3 ]
then
    echo "search string is too short, exiting..."
    exit 0
fi

shopt -s nocasematch #case insensitive

min_commits=10000 # this can be updated to reflect more commits

declare -a commits_ar
declare -a commit_authors_ar

#IFS=$'\n'; 
commits_ar=$(git log | grep "^commit" | head -${min_commits} | cut -d' ' -f2 | tr "\n" " ")
commit_authors_ar=$(git log | grep "^commit" -A1 | grep "Author" | head -${min_commits} | tr " " "_" | tr "\n" " ")

n=1 # start comparing of commits 0 to 1, 1 to 2, 2 to 3 and so on
found=false

for author in "${commit_authors_ar[@]}"
do
	#echo "commit[$((n-1))]=${commits_ar[n-1]}"
	#echo "commit author=$author"
	if [ "$n" -gt "$min_commits" ]; then break; fi
	
	if [[ $author =~ $var_search_string ]] 
	then
		
		#git diff "${commits_ar[0]}..${commits_ar[n]}"
		#nm=n-1
		
		echo -e "\e[32mcommit[$((n-1))]=${commits_ar[n-1]}"
		strings=$(git diff "${commits_ar[n]}..${commits_ar[n-1]}" | grep -v "diff --git " | grep -v -E '^index [[:alnum:]]{8}')
                echo -e "\e[91m$var_search_string is an author of commit No:$((n-1))"
                commit_author=$(echo $author | tr "_" " ")
                echo -e "\e[93mmade by $commit_author"
                echo -e "\e[93mpushed changes are as follows:"
                echo -e "\e[1;94;49m$strings"
                echo -e "\e[0m"



		found=true
	fi
	

	
	let n++
	
done

if [[ $found == false ]]
then
	echo -e "nothing was added within last\e[91m $min_commits\e[0m commits by author: \e[91m$var_search_string"
	echo -e "\e[0m"
fi





