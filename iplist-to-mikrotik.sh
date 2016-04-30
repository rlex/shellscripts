#!/bin/sh
#Simple script to convert list of ip addresses to mikrotik address-list import file
#This can be used to bypass, for example, country firewall - just route blocked IP via VPN gw
#Can also parse IPs from any text file (ie csv)
#to import to mikrotik:
#/tool fetch url=https://example.com/crapregistry.rsc dst-path=crapregistry.rsc
#/import crapregistry.rsc
#As for routing part:
#/ip route rule
#add action=lookup-only-in-table comment="Russian firewall force" dst-address=0.0.0.0/0 routing-mark=russianbl src-address=0.0.0.0/0 table=russianbl
#/ip route
#add comment="Russian blocklist bypass" distance=1 gateway=$YOUR_VPN_INTERFACE routing-mark=russianbl
#/ip firewall mangle
#add action=mark-routing chain=prerouting comment="Great Russian Firewall" dst-address-list=russianbl new-routing-mark=russianbl passthrough=no

#SETTINGS
#url of input file
url="https://raw.githubusercontent.com/zapret-info/z-i/master/dump.csv"
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
sed -n 's/\([0-9]\{1,3\}\.\)\{3\}[0-9]\{1,3\}/\nIPINDEX&\n/gp' $downfile | grep IPINDEX | sed 's/IPINDEX//'| sort | uniq >> $infile
#We need to drop all previous IPs in this address list because mikrotik does not check for duplicates (and they may be removed from file)
echo /ip firewall address-list remove [find list=$list] > $outfile
#Build rsc file...
for line in $(cat $infile)
    do
        echo /ip firewall address-list add address="$line" list="$list" >> $outfile
    done
rm $downfile $infile
