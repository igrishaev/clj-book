#!/usr/bin/env sh

grep \footurl *.tex |
while read -r row ; do
    file=$(echo $row | grep -o '\w*-\w*.tex')
    url=$(echo $row | grep -Eo 'https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)' | sed -e "s/\\\//g")
    urlstatus=$(curl -o  /dev/null --connect-timeout 7 --silent --head -L --write-out '%{http_code}' "$url" )
    echo "$url  $urlstatus"
    if [ $urlstatus -ne 200 ];
    then
        echo "Error status for url: $url in file: $file"
        exit 1;
    fi
done
