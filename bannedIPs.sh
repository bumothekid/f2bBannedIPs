#Copyright (c) <year>, <copyright holder>
#All rights reserved.

#This source code is licensed under the MIT-style license found in the
#LICENSE file in the root directory of this source tree. 

# Display static header
echo "\e[1;44m        List of Banned IPs         \n\e[0m"

# Fetch dynamic info
IPs=$(sudo fail2ban-client status sshd | grep "Banned IP list:" | sed 's/.*Banned IP list://g' | tr -s ' ' '\n')
current_status=$(sudo fail2ban-client status sshd)
currently_banned=$(echo "$current_status" | grep "Currently banned:" | sed 's/.*Currently banned://g')
total_banned=$(echo "$current_status" | grep "Total banned:" | sed 's/.*Total banned://g')

# Display Currently Banned IPs and Total Banned to Date
echo "\e[1;32m   Currently Banned IPs: $currently_banned\e[0m"
echo "\e[1;32m   Total Banned to Date: $total_banned\n\e[0m"

# Display table headers
echo " ┌─────┬──────────────────────┬───────────┐"
echo " │ No. │          IP          │  Unban In │"
echo " ├─────┼──────────────────────┼───────────┤"

# Parse each IP and look up its ban time in the log file
counter=1
echo "$IPs" | while read -r ip; do
  if [ -z "$ip" ]
  then
    printf " │     │     No IPs banned    │           │\n"
  else
    ban_time=$(sudo grep "$ip" /var/log/fail2ban.log | tail -1 | awk '{print $1 " " $2}' | xargs -I {} date -d {} +%s)
    current_time=$(date +%s)
    time_left=$(( 3600 - (current_time - ban_time) ))
    mins=$(( (time_left + 59) / 60 ))
    [ $mins -eq 0 ] && mins=1
    printf " │ %2d  │     %-15s  │%4d mins  │\n" "$counter" "$ip" "$mins"
    counter=$((counter+1))
  fi
  done
echo " └─────┴──────────────────────┴───────────┘"  # Line below each IP

echo "\e[1;32m  Current Time: $(date '+%H:%M:%S')\e[0m"
echo " ──────────────────────────────────────────"
