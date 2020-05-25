#!/bin/bash
echo "  {" >> seclist-waf-TCP443.json
echo "        \"icmp-options\": null,">> seclist-waf-TCP443.json
echo "        \"is-stateless\": false,">> seclist-waf-TCP443.json 
echo "        \"protocol\": \"6\",">> seclist-waf-TCP443.json
echo "        \"source\": $1,">> seclist-waf-TCP443.json
echo "        \"source-type\": \"CIDR_BLOCK\",">> seclist-waf-TCP443.json
echo "        \"tcp-options\": {">> seclist-waf-TCP443.json
echo "          \"destination-port-range\": {">> seclist-waf-TCP443.json
echo "            \"max\": 443,">> seclist-waf-TCP443.json
echo "            \"min\": 443">> seclist-waf-TCP443.json
echo "          },">> seclist-waf-TCP443.json
echo "          \"source-port-range\": null">> seclist-waf-TCP443.json
echo "        },">> seclist-waf-TCP443.json
echo "        \"udp-options\": null">> seclist-waf-TCP443.json
echo "      },">> seclist-waf-TCP443.json
