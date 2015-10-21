srr_jenkins Cookbook
======================
This cookbook installs the latest version of jenkins

Requirements
------------
CentOS 6.x

#### packages
- 'srr_iptables' - srr_jenkins needs srr_iptables to redirect port 80 and 443.
- 'srr_jdk' - srr_jenkins needs srr_jdk to install and configure java
- 'srr_deploy' - srr_jenkins needs srr_deploy to give access to the standard deploy account


Attributes
----------
TODO: List your cookbook attributes here.

e.g.
#### srr_jenkins::default
<table>
  <tr>
    <th>['srr_jenkins']['version']</th>
    <th>String</th>
    <th>THIS DOES NOT WORK AT THIS TIME. Version of Jenkins to install.</th>
    <th>"1.599-1.1"</th>
  </tr>
  <tr>
    <td><tt>['srr_jenkins']['use_ssl']</tt></td>
    <td>String</td>
    <td>whether to setup SSL</td>
    <td><tt>"true"</tt></td>
  </tr>
  <tr>
    <td><tt>['srr_jenkins']['ssl']['country']</tt></td>
    <td>String</td>
    <td>The country for the SSL certificate</td>
    <td><tt>"US"</tt></td>
  </tr>
  <tr>
    <td><tt>['srr_jenkins']['ssl']['state']</tt></td>
    <td>String</td>
    <td>The state for the SSL certificate</td>
    <td><tt>"Kentucky"</tt></td>
  </tr>
  <tr>
    <td><tt>['srr_jenkins']['ssl']['locality']</tt></td>
    <td>String</td>
    <td>The city or town for the SSL certificate</td>
    <td><tt>"Lexington"</tt></td>
  </tr>
  <tr>
    <td><tt>['srr_jenkins']['ssl']['organization']</tt></td>
    <td>String</td>
    <td>The organization for the SSL certificate</td>
    <td><tt>"The Jockey Club"</tt></td>
  </tr>
  <tr>
    <td><tt>['srr_jenkins']['ssl']['unit']</tt></td>
    <td>String</td>
    <td>The business unit for the SSL certificate</td>
    <td><tt>"The Jockey Club Technology Services"</tt></td>
  </tr>
  <tr>
    <td><tt>['srr_jenkins']['ssl']['email']</tt></td>
    <td>String</td>
    <td>The email for the SSL certificate</td>
    <td><tt>""</tt></td>
  </tr>
  <tr>
    <td><tt>['srr_jenkins']['ssl']['keypassword']</tt></td>
    <td>String</td>
    <td>The password for the key SSL certificate</td>
    <td><tt>"jenkins"</tt></td>
  </tr>
  <tr>
    <td><tt>['srr_jenkins']['ssl']['storepassword']</tt></td>
    <td>String</td>
    <td>The password for the key store p12 file and jks file</td>
    <td><tt>"jenkins"</tt></td>
  </tr>
  <tr>
    <td><tt>['srr_jenkins']['ssl']['sslfilepath']</tt></td>
    <td>String</td>
    <td>The path for the SSL certificate files</td>
    <td><tt>"/var/lib/jenkins/ssl"</tt></td>
  </tr>
  <tr>
    <td><tt>['srr_iptables']['rules']</tt></td>
    <td>String</td>
    <td>The rules for iptables. Includes redirects for ports 80 and 443</td>
    <td><tt>"*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
-A INPUT -p icmp -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 22 -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 80 -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 443 -j ACCEPT

#Tomcat
-A INPUT -m state --state NEW -m tcp -p tcp --dport 8080 -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 8005 -j ACCEPT

#Tomcat JMX monitoring
-A INPUT -m state --state NEW -m tcp -p tcp --dport 10080 -j ACCEPT

#Tomcat multicast
-A INPUT -m state --state NEW -m tcp -p tcp --dport 45564 -j ACCEPT
-A INPUT -m state --state NEW -m udp -p udp --dport 45564 -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 4000:4100 -j ACCEPT

#Zabbix agent
-A INPUT -m state --state NEW -m tcp -p tcp --dport 10050 -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 10051 -j ACCEPT

#Jenkins
-A INPUT -m state --state NEW -m tcp -p tcp --dport 8443 -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 8009 -j ACCEPT

-A INPUT -j REJECT --reject-with icmp-host-prohibited
-A FORWARD -j REJECT --reject-with icmp-host-prohibited

##  uncomment below to turn on iptables logging
##  you should comment out the two REJECT items above while you test
##  look at /var/log/messages for IPTables-Dropped:
#-N LOGGING
#-A INPUT -j LOGGING
#-A LOGGING -m limit --limit 20/min -j LOG --log-prefix \"IPTables-Dropped: \" #--log-level 4
#-A LOGGING -j DROP

COMMIT


*nat
:PREROUTING ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]

#Redirects for jenkins
-A PREROUTING -i eth0 -p tcp --dport 443 -j REDIRECT --to-port 8443
-A PREROUTING -i eth0 -p tcp --dport 80 -j REDIRECT --to-port 8080

COMMIT
"</tt></td>
  </tr>
</table>

Usage
-----
#### srr_jenkins::default

## Use a wrapper cookbook ##
In your metadata.rb: add the line 'depends srr_jenkins'
In your recipes/default.rb: add the line 'include_recipe srr_jenkins'
In your attributes/default.rb: Override any attributes you like.


Or just include `srr_jenkins` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[srr_jenkins]"
  ]
}
```


License and Authors
-------------------
Authors: Steven Riggs
