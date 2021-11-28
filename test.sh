#!/bin/bash
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

echo it starts

i=1
while [ $i -le 5 ]; do
  echo i is $i
  i=$(( i+1 ))
done

echo "kosong"
