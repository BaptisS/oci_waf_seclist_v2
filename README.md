# Lockdown OCI WAF Origin using CloudShell (SecList) #
_An easy way to lockdown your OCI WAF Origin_ 


After configuring OCI Web Application Firewall policy, it's crucial to apply a set of security rules around your Web Application in order to block requests not passing through the WAF service.

OCI WAF stands in front of your web application to detect and block unwanted/malicious requests. In most cases, your Web Application itself sits behind a Load Balancer. (End-users --> OCI WAF --> OCI LBaaS --> WEBApp) 

In OCI, all network communication are blocked by default unless you have security rule assigned to proper subnet and/or Vnic. 

Depending on your architecture and preferences, you may want to assign security rules to your Load Balancer's subnet by using a Security List, or alternatively you may prefer to assign the security rules to your Load Balancer Network Interfaces by using Network Security Group.

This document will guide you through the steps needed to create and assign a ***Security List*** containing a list of OCI WAF public IP addresses used to send the traffic to your load balancer / Web Application. If you want to use _Network Security Groups_ for this purpose please consult the following guide : https://github.com/BaptisS/oci_waf_nsg_v2



> ***Note:*** 
> If you are not using a Load Balancer in front of your Web Application (End-users --> OCI WAF --> WebApp), Security rules (Security List / Network Security Group) must be applied directly to your Web Application subnet (if using Security Lists) or Network Interfaces (if using network Security Groups).


***Prerequisites:***

- OCI user account with enough permissions. (Create and assign Security Lists / NSG) in desired Compartment & VCN. 
- Virtual Cloud Network (VCN) and one Subnet already created. 
 
 
 
 
### 1- Create a New (empty) Security List.    

 1.1-	Sign-in to the OCI web console with your OCI user account. 

1.2-	Open the OCI Menu (top left), expand the ***‘Networking’*** section and click on ***‘Virtual Cloud Networks’***.  

1.3-	Click on your VCN then select the ***‘Security Lists’*** Resources type. 

![PMScreens](https://raw.githubusercontent.com/BaptisS/oci_waf_seclist/master/img/01.jpg)

1.4-	Click on the ***‘Create Security List’*** button. 

![PMScreens](https://raw.githubusercontent.com/BaptisS/oci_waf_seclist/master/img/02.jpg)

1.5-	Provide a meaningful name for this new security list. (Ie. ‘OCIWAF-SL’)

1.6-	Select proper compartment, then click on ***‘Create Security List’*** button. 

1.7-	Highlight the newly created Security list and select ***‘Copy OCID’*** in its right menu. 

![PMScreens](https://raw.githubusercontent.com/BaptisS/oci_waf_seclist/master/img/03.jpg)
 
### 2-    Import Security Rules using Cloud Shell commands.

2.1-	Start your OCI Cloud Shell session. In the OCI Console top right section, click on the Cloud Shell icon:  

![PMScreens](https://raw.githubusercontent.com/BaptisS/oci_waf_seclist/master/img/04.jpg)

2.2-	Wait few seconds for your Cloud Shell instance to be started and ready to use.

![PMScreens](https://raw.githubusercontent.com/BaptisS/oci_waf_seclist/master/img/05.jpg)

2.3-	Copy and Paste (CTRL+SHIFT+’V’) the command below in your Cloud Shell session.

```
wafseclist=ocid1.securitylist.oc1.eu-frankfurt-1.aaaaaaaxxxxx
```
(Replace ‘ocid1.securitylist.oc1.eu-frankfurt-1.aaaaaaaxxxxx’ by your Security List OCID copied in the previous step.)

![PMScreens](https://raw.githubusercontent.com/BaptisS/oci_waf_seclist/master/img/06.jpg)


> ***Important Note:*** 
> The content of the selected Security List will be overwritten by the OCI WAF security rules during the next step. 
> We strongly advise to create a new (empty) security list for this purpose. (As Described in this document)   



2.4-	Allow inbound **HTTPS (TCP443) only**

2.4.1- 	Copy and Paste (_CTRL+SHIFT+V_) the commands below in your Cloud Shell session.

```
#!/bin/bash
rm -f wafrule-TCP443.sh
wget https://raw.githubusercontent.com/BaptisS/oci_waf_seclist_v2/master/wafrule-TCP443.sh
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
```

2.4.2- Review your newly created security list to ensure you now have +50 rules inside. 


### 4-   Assign the Security List to the desired subnet.
4.1-	Go to your VCN dashboard, and then select the ***‘Subnets’*** Resources section. 

![PMScreens](https://raw.githubusercontent.com/BaptisS/oci_waf_seclist/master/img/08.jpg)

4.2-	Click on the desired subnet name (LBaaS/WebApp subnet). 

![PMScreens](https://raw.githubusercontent.com/BaptisS/oci_waf_seclist/master/img/09.jpg)

4.3-	Click on ***‘Add Security List’*** button.  

4.4-	Select the newly created Security List (Ie. OCIWAF-SL)  

![PMScreens](https://raw.githubusercontent.com/BaptisS/oci_waf_seclist/master/img/10.jpg)

4.5-	Click ***‘Add Security List’*** button to assign the Security to the subnet.  

![PMScreens](https://raw.githubusercontent.com/BaptisS/oci_waf_seclist/master/img/11.jpg)

### 5-   Remove any permissive rules 
5.1-	Once you've assigned the new security list which contains the required security rules to allow inbound traffic from OCI WAF endpoints, you can remove any other ( more permissive ) pre-existing rules to lockdown your WAF Origin and allow only inbound traffic from the OCI WAF services.




## Links and References : 


OCI WAF documentation and Public IPS list : https://docs.cloud.oracle.com/en-us/iaas/Content/WAF/Concepts/gettingstarted.htm


OCI CloudShell : https://docs.cloud.oracle.com/en-us/iaas/Content/API/Concepts/cloudshellintro.htm


OCI WAF CLI References : https://docs.cloud.oracle.com/en-us/iaas/api/#/en/waas/latest/

