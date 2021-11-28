#!/bin/csh
echo "gass"
while [ true ] ;
do
read -p "Enter Your Machine Name : " server
if [[ ! -z "${server}" ]];
then
	printf "$server\n"
break;
fi
done

echo "kosong"
