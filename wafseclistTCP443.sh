#!/bin/bash
wget https://raw.githubusercontent.com/BaptisS/oci_waf_seclist/master/wafrule-TCP443.sh
chmod +x wafrule-TCP443.sh
wafips=$(oci waas edge-subnet list --all)
wafcidrs=$(echo $wafips | jq '.data[] | .cidr')

rm -f seclist-waf-TCP443.json
rm -f seclist-waf-TCP443_fixed.json

echo "[" >> seclist-waf-TCP443.json
for cidr in $wafcidrs; do ./wafrule-TCP443.sh $cidr ; done
echo "]" >> seclist-waf-TCP443.json
sed -i 's+66.254.103.241+66.254.103.241/32+g' seclist-waf-TCP443.json                                            
sed -zr 's/,([^,]*$)/\1/' seclist-waf-TCP443.json > seclist-waf-TCP443_fixed.json
oci network security-list update --security-list-id $wafseclist --ingress-security-rules file://seclist-waf-TCP443_fixed.json --force

rm -f seclist-waf-TCP443.json
rm -f seclist-waf-TCP443_fixed.json
rm -f wafrule-TCP443.sh
