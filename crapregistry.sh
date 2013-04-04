#SETTINGS
#url of ip-addr list
url="http://api.antizapret.info/group.php"
#address list in mikrotik
list="russianbl"
#input file with list of IPs
infile="/tmp/craptmp.txt"
#outfile
outfile="/tmp/crapregistry.txt"

wget $url -O $infile
#sort -t . -k 1,1n -k 2,2n -k 3,3n -k 4,4n $INFILE > $INFILE
echo /ip firewall address-list remove [find list=$list] > $outfile
for line in $(cat /tmp/craptmp.txt)
do
echo /ip firewall address-list add address="$line" list="$list" >> $outfile
done

