# good_scripts
**Various Bash and Python Scripts that can make your life easier :-)**

1. Create Playlist - this is a simple utility you can use to create extended M3U playlist from files located either at the same directory or one level deeper. It will also manipulate with the existing files and folders by renaming them: removing percent signs, square brackets "[]", double dashes and double spaces. 
  a) The usage is self explanatory when you open the script. By default it is made for *.mp4, but you can add the argument, -e "*.avi"  to change this behaviour. It also deletes some dummy substring from all file names as necessary, which you can modify from within the script, but pls note - it is case-insensitive. 

**TWO GIT TRACKING UTILITIES, WHICH EXTRACT INFORMATION FROM YOUR GIT REPOSITORIES**__

2. Find Guilty Line - use this script to find a line within your git repo, which was added any 'commits' ago and you want to identify how / by whom it was added. 
3. Find Guyilty Author - this script is similar to above but uses **author name** to find all commits submitted by a particular person, another, very useful option for git users.
