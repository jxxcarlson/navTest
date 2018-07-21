color=`tput setaf 48`
magenta=`tput setaf 5`
reset=`tput setaf 7`

echo
echo "${color}Compile app${reset}"
/Users/carlson/Downloads/2/elm make ./src/Main2.elm 

if [ "$1" = "-r" ]
then
echo
echo "${color}Start web server on port 8080${reset}"
http-server ./dist
fi
