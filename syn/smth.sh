#!/bin/bash

while read cmd
do
    echo "Extracting $cmd"

    genus -batch <<EOF >> genus_help.txt
$cmd -help
exit
EOF

done < commands.txt
