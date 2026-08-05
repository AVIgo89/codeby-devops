#!/bin/bash

if [ ! -d /home/user/DevOps/codeby-devops/lesson10/myfolder ]; then
    echo "Error /home/user/DevOps/codeby-devops/lesson10/myfolder not. Run script1.sh"
    exit 1
fi

file_count=$(find /home/user/DevOps/codeby-devops/lesson10/myfolder -maxdepth 1 -type f | wc -l)
echo "In myfolder - $file_count file."

if [ -f /home/user/DevOps/codeby-devops/lesson10/myfolder/file2.txt ]; then
    chmod 664 /home/user/DevOps/codeby-devops/lesson10/myfolder/file2.txt
    echo "file2.txt > 664."
else
    echo "File file2.txt not."
fi

echo "Find..."
empty_files=$(find /home/user/DevOps/codeby-devops/lesson10/myfolder -maxdepth 1 -type f -empty)
if [ -n "$empty_files" ]; then
    echo "File pusto:"
    echo "$empty_files"
    find /home/user/DevOps/codeby-devops/lesson10/myfolder -maxdepth 1 -type f -empty -delete
    echo "File delete."
else
    echo "File pusto not."
fi

for file in /home/user/DevOps/codeby-devops/lesson10/myfolder/file*.txt; do
    if [ -f "$file" ]; then
        if [ -s "$file" ]; then
            head -n 1 "$file" > "$file.tmp"
            mv "$file.tmp" "$file"
            echo "Ok: $(basename "$file")"
        fi
    fi
done

echo "Ok script2"
