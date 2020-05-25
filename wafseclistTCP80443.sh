#!/bin/bash
rm -f wafrule-TCP80.sh
rm -f wafrule-TCP443.sh
wget https://raw.githubusercontent.com/BaptisS/oci_waf_seclist_v2/master/wafrule-TCP80.sh
wget https://raw.githubusercontent.com/BaptisS/oci_waf_seclist_v2/master/wafrule-TCP443.sh
chmod +x wafrule-TCP80.sh
chmod +x wafrule-TCP443.sh

wafips=$(oci waas edge-subnet list --all)
wafcidrs=$(echo $wafips | jq '.data[] | .cidr')

rm -f seclist-waf-TCP80443-temp.json
rm -f seclist-waf-TCP80443.json
rm -f seclist-waf-TCP443.json


echo "[" >> seclist-waf-TCP80443-temp.json
for cidr in $wafcidrs; do ./wafrule-TCP80.sh $cidr ; done
for cidr in $wafcidrs; do ./wafrule-TCP443.sh $cidr ; done
cat seclist-waf-TCP443.json >> seclist-waf-TCP80443-temp.json
echo "]" >> seclist-waf-TCP80443-temp.json
sed -i 's+66.254.103.241+66.254.103.241/32+g' seclist-waf-TCP80443-temp.json                                            
sed -zr 's/,([^,]*$)/\1/' seclist-waf-TCP80443-temp.json > seclist-waf-TCP80443.json
rm -f seclist-waf-TCP80443-temp.json
oci network security-list update --security-list-id $wafseclist --ingress-security-rules file://seclist-waf-TCP80443.json --force


rm -f wafrule-TCP80.sh
rm -f wafrule-TCP443.sh

rm -f seclist-waf-TCP80443-temp.json
rm -f seclist-waf-TCP80443.json
rm -f seclist-waf-TCP443.json
