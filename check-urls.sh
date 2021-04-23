#!/usr/bin/env sh

RED='\033[0;31m';
NC='\033[0m';

grep '}{http' *.tex |
while read row ; do
    file=$(echo $row | grep -o '\w*.tex')
    url=$(echo $row | sed -e "s/\\\//g" | pcregrep -Mo 'https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)');
    if [ "$url" == "" ];
    then
       continue;
    fi
    urlstatus=$(curl -o  /dev/null --connect-timeout 7 --silent --head -L --write-out '%{http_code}' "$url" )
    echo "$url  $urlstatus"
    if [ $urlstatus -ne 200 ];
    then
        echo "${RED}Error status for url: $url in file: $file ${NC}"
        continue;
    fi
done
