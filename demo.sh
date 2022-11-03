#/bin/bash

URL=${URL:-localhost:8080}

RESP=$(curl -D- "$URL/auth/v1.0" -H "X-Auth-User: test:tester" -H "X-Auth-Key: testing" 2>1)
TOKEN=$(echo "$RESP" | awk '/X-Auth-Token:/ {printf "%s", $2}' | tr -d '\r')
STORAGE_URL=$(echo "$RESP" | awk '/X-Storage-Url:/ {printf "%s", $2}' | tr -d '\r')

echo "Storage URL: $STORAGE_URL"

echo Create container

curl -X PUT -i -H "X-Auth-Token: $TOKEN" $STORAGE_URL/testcontainer

echo List containers:

curl -X GET -i -H "X-Auth-Token: $TOKEN" $STORAGE_URL

echo Contents of container:

curl -X GET -i -H "X-Auth-Token: $TOKEN" $STORAGE_URL/testcontainer

echo Metadata of container:

curl -X HEAD -i -H "X-Auth-Token: $TOKEN" $STORAGE_URL/testcontainer

echo Put object:

curl -X PUT -i -H "X-Auth-Token: $TOKEN" -T demo.sh $STORAGE_URL/testcontainer/testobject

echo Retrieve object

curl -X GET -H "X-Auth-Token: $TOKEN" -o retrieved_demo.sh $STORAGE_URL/testcontainer/testobject
