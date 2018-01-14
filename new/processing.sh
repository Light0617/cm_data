#! /bin/bash

for file in `find "/tmp/data" -name "*.cm"`; do
	echo $file
	sed 's/^[ \t]*//;s/[ \t]*$//' < $file > $file+'k' 
done 
