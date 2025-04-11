@#!/bin/bash@
IFS=$'\n'
while read line
do
if [[ "$line" == *"tg_url:"* ]]; then
    ADR=${line:9:$( expr ${#line} - 10 )}
fi
if [[ "$line" == *"tg_token_url:"* ]]; then
    TOKEN_ADR=${line:15:$( expr ${#line} - 16 )}
fi
done < $TG_URL_PATH
echo $ADR
echo $TOKEN_ADR
######
Token=$(curl -s --location -u $APIM_CONSUMER_KEY:$APIM_CONSUMER_SECRET -k "$TOKEN_ADR" --header 'Content-Type: application/json' --data '{}' | awk -F "\"" '{print $4}')
#######
T='{"token":"'$TG_DEBUG_BOT_TOKEN'","id":"'$TG_DEBUG_GROUP_ID'","text":"'$MY_RESULT'"}'
curl -k -H "Content-type: application/json" -H "AuthorizationWSO: Bearer $(echo $Token)" -X POST -d "$T" "$ADR"
#curl -k -H "Content-type: application/json" -X POST -d "$T" "$ADR"