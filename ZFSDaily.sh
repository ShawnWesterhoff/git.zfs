#!/usr/local/bin/bash
# ZFS Snapshot BASH script by Shawn Westerhoff
# Updated 1/14/2014 and again to demo git

### DATE VARIABLES
# D = Today's date
# D1 = Yesterday's date
# D# = Today less # days date
Y=$(date -v-1d '+%m-%d-%Y')
D=$(date +%m-%d-%Y)
D1=$(date -v-1d '+%m-%d-%Y')
D10=$(date -v-10d '+%m-%d-%Y')
D20=$(date -v-20d '+%m-%d-%Y')

# Step 1: Make the snapshots

for i in $( zfs list -H -o name ); do
	if [ $i == tier1 ]
	then echo "$i found, skipping"
	else
	zfs snapshot $i@$D
	fi
done

# Step 2: Send the snapshots to backup ZFS sever

	for i in $( zfs list -H -o name ); do
        zfs send -i $i@$D1 $i@$D | ssh -c arcfour root@10.111.100.52 zfs recv $i
	done

# Step 3: Destroy snapshots that are 20 days old

for i in $( zfs list -H -o name ); do
        if [ $i == tier1 ]
        then
        	echo "$i found, skipping"
        	echo "$i found, skipping ahead"
        else
        zfs destroy $i@$D20
        fi
done

# Step 4: Email Logs
zpool status -xT d | mail -s "Nexxo ZFS Daily" YOUR-EMAIL-HERE