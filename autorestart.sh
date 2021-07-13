#!/bin/bash
 
CheckURL="url-domainmu"
 
STATUS_CODE=`curl -o /dev/null -m 10 --connect-timeout 60 -s -w %{http_code} $CheckURL`

echo "$CheckURL Status Code: $STATUS_CODE"
if [ "$STATUS_CODE" -ne "200" ]; then
        systemctl restart nginx mysqld
fi
