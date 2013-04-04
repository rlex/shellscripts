#!/bin/sh
#Simple script to convert list of ip addresses to 
#Mikrotik import file (address list feature)
#Can also parse IPs from any text file (ie csv)

#SETTINGS
#url of input file
url="http://api.antizapret.info/group.php"
#address list in mikrotik
list="russianbl"
#Where to download source file
downfile="/tmp/templist.txt"
#File with cleaned & formatted ip addresses
infile="/tmp/craplist.txt"
#Where to put rsc script
outfile="/tmp/crapregistry.rsc"

wget $url -O $downfile
#This will extract all IPs from file (ie works with .csv russian blocklist)
sed -n 's/\([0-9]\{1,3\}\.\)\{3\}[0-9]\{1,3\}/\nip&\n/gp' $downfile | grep ip | sed 's/ip//'| sort | uniq >> $infile
#We need to drop all IPs in address list because mikrotik does not check for duplicates (and they may be removed from file)
echo /ip firewall address-list remove [find list=$list] > $outfile
#Build rsc file...
for line in $(cat $infile) 
    do
        echo /ip firewall address-list add address="$line" list="$list" >> $outfile
    done
rm $downfile $infile
