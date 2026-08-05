#!/bin/bash

mkdir -p /home/user/DevOps/codeby-devops/lesson10/myfolder

echo "Hello, 1 file!" > /home/user/DevOps/codeby-devops/lesson10/myfolder/file1.txt
date >> /home/user/DevOps/codeby-devops/lesson10/myfolder/file1.txt

touch /home/user/DevOps/codeby-devops/lesson10/myfolder/file2.txt
chmod 777 /home/user/DevOps/codeby-devops/lesson10/myfolder/file2.txt

random_string=$(tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c 20)
echo "$random_string" > /home/user/DevOps/codeby-devops/lesson10/myfolder/file3.txt

touch /home/user/DevOps/codeby-devops/lesson10/myfolder/file4.txt

touch /home/user/DevOps/codeby-devops/lesson10/myfolder/file5.txt

echo "OK!!!"
