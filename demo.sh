echo Create container

curl -X PUT -i -H "X-Auth-Token: $TOKEN" $URL/testcontainer

echo List containers:

curl -X GET -i -H "X-Auth-Token: $TOKEN" $URL

echo Contents of container:

curl -X GET -i -H "X-Auth-Token: $TOKEN" $URL/testcontainer

echo Metadata of container:

curl -X HEAD -i -H "X-Auth-Token: $TOKEN" $URL/testcontainer

echo Put object:

curl -X PUT -i -H "X-Auth-Token: $TOKEN" -T demo.sh $URL/testcontainer/testobject

echo Retrieve object

curl -X GET -H "X-Auth-Token: $TOKEN" -o retrieved_demo.sh $URL/testcontainer/testobject
