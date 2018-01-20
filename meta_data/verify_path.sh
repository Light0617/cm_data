set -e
while read line; do 
ls "$line"; 
done
set +e
