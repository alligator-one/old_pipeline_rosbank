@#!/bin/bash@
IFS=$'\n'
while read line
do
if [[ "$line" == *"tg_url:"* ]]; then
    ADR=${line:9:$( expr ${#line} - 10 )}
fi
done < $TG_URL_PATH
echo $ADR
T='{"token":"'$TG_DEBUG_BOT_TOKEN'","id":"'$TG_DEBUG_GROUP_ID'","text":"'$MY_RESULT'"}'
curl -k -H "Content-type: application/json" -X POST -d "$T" "$ADR"