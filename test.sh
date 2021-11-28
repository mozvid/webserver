#!/bin/bash
read -p "Enter Your Machine Name : " server
while [[ -z "${server}" ]]; do
    read -p "Enter Your Machine Name : " server
done
echo "servername = $server"
