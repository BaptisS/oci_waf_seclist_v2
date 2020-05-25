#!/bin/bash
echo "  {" >> seclist-waf-TCP80443-temp.json
echo "        \"icmp-options\": null,">> seclist-waf-TCP80443-temp.json
echo "        \"is-stateless\": false,">> seclist-waf-TCP80443-temp.json 
echo "        \"protocol\": \"6\",">> seclist-waf-TCP80443-temp.json
echo "        \"source\": $1,">> seclist-waf-TCP80443-temp.json
echo "        \"source-type\": \"CIDR_BLOCK\",">> seclist-waf-TCP80443-temp.json
echo "        \"tcp-options\": {">> seclist-waf-TCP80443-temp.json
echo "          \"destination-port-range\": {">> seclist-waf-TCP80443-temp.json
echo "            \"max\": 80,">> seclist-waf-TCP80443-temp.json
echo "            \"min\": 80">> seclist-waf-TCP80443-temp.json
echo "          },">> seclist-waf-TCP80443-temp.json
echo "          \"source-port-range\": null">> seclist-waf-TCP80443-temp.json
echo "        },">> seclist-waf-TCP80443-temp.json
echo "        \"udp-options\": null">> seclist-waf-TCP80443-temp.json
echo "      },">> seclist-waf-TCP80443-temp.json
