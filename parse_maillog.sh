#!/bin/bash

# Check all required arguments are provided
if [ "$#" -ne 4 ]; then
  echo "Usage: $0 <mail_log> <log_date> <sender_domain> <recipient_domain>"
  echo "Example: $0 mail.log 'Aug 18' domain_1.example.com domain_2.example.com"
  exit 1
fi

# Assign input arguments to variables
mail_log=$(readlink -f $1)
log_date=$2
sender_domain=$3
recipient_domain=$4

echo "Step 1: Get queue ID list for sender domain"
# Find all queue IDs for sender domain
grep ''"$log_date"'.*.from=<.*.@'$sender_domain'>' "$mail_log" | cut -d ' ' -f 6 | sed 's/.$//' >> queue_id_list

echo "Step 2: Remove duplicates from sender queue ID list"
awk -i inplace '!seen[$0]++' queue_id_list

echo "Step 3: Get sender recipient pairs..."
input="queue_id_list"
# Read file with sender domain queue IDs line by line
while IFS= read -r ID
do
# If found log message with "status=sent" for certain ID then
# put values into file tmp_result
    if [ ! -z "$(grep ''"$log_date"'.*.'$ID'.*.to=<.*.@'$recipient_domain'>.*.status=sent' "$mail_log")" ]; then
      FROM="$(grep ''"$log_date"'.*.'$ID'.*.from=<.*.@'$sender_domain'>' "$mail_log" | cut -d ' ' -f 7 | awk -F'[<>]' '{print $2}' | head -1)"
      grep ''"$date"'.*.'$ID'.*.to=<.*.@'$recipient_domain'>.*.status=sent' "$mail_log" | while read -r line ; do
        TO="$(echo "$line" | cut -d ' ' -f 7 | awk -F'[<>]' '{print $2}')"
        DATE="$(echo "$line" | cut -d ' ' -f 1-3)"
        echo -e "${ID}\t${DATE}\t${FROM}\t${TO}" >> tmp_result
      done
    fi
done < "$input"

echo "Step 4: Format output and cleanup"
RESULT=mail_$(date +"%Y-%m-%d_%H%M")
cat tmp_result | column -t > $RESULT
rm tmp_result
rm queue_id_list

echo "Complete! Report file $(readlink -f $RESULT)"
