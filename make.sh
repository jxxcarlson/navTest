color=`tput setaf 48`
magenta=`tput setaf 5`
reset=`tput setaf 7`

if [ "$1" = "-s" ]
then
echo
echo "${color}  -s:  Simple compile app to index.html${reset}"
/Users/carlson/Downloads/2/elm make ./src/Main.elm
echo
echo "${color}Copy files to  /usr/local/var/www/ and restart nginx${reset}"
nginx -s stop
cp ./index.html /usr/local/var/www/
nginx
fi

if [ "$1" = "-i" ]
then
echo
echo "${color}  -i: Compile app to Main.js, use index.html${reset}"
/Users/carlson/Downloads/2/elm make ./src/Main.elm --output Main.js
echo
echo "${color}Copy files to  /usr/local/var/www/ and restart nginx${reset}"
nginx -s stop
cp ./src/index.html /usr/local/var/www/
cp ./Main.js /usr/local/var/www/
nginx
fi

