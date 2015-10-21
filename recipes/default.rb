#
# Cookbook Name:: srr_jenkins
# Recipe:: default
#
# Copyright 2015, Steven Riggs
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# TODO:  Maybe watching for the certificate expiration and
#        deleting the certificates will work.  This will
#        trigger a remake of the certificates


include_recipe 'srr_iptables'
include_recipe 'srr_jdk'
include_recipe 'srr_deploy'


#download the jenkins repo file
remote_file "/etc/yum.repos.d/jenkins.repo" do
	source "http://pkg.jenkins-ci.org/redhat/jenkins.repo"
	not_if { File.exist?("/etc/yum.repos.d/jenkins.repo") }
end


execute "Import the jenkins-ci.org key" do
  command "rpm --import https://jenkins-ci.org/redhat/jenkins-ci.org.key"
  #you can get the key information by gpg --with-fingerprint YOURKEY
  #match it with the rpm key database rpm -q gpg-pubkey

  # TODO: this only_if isn't working
  #not_if { "rpm -q gpg-pubkey | grep d50582e6" }
end


#install jenkins
package 'jenkins' do
	#version "#{node['srr_jenkins']['version']}"
	# TODO: Installer complains about the version but version "#{node['srr_jenkins']['version']}" doesn't fix the problem
	action :install
end



#Setup SSL
#Reference: http://balodeamit.blogspot.com/2014/03/jenkins-switch-to-ssl-https-mode.html
if node['srr_jenkins']['use_ssl'] == "true"
	directory "/var/lib/jenkins/ssl"

	bash "Create the SSL certificates for jenkins" do
		code <<-EOS
			echo --> Generate the server private key <--
			openssl genrsa \
				-des3 \
				-out #{node['srr_jenkins']['ssl']['sslfilepath']}/#{node['fqdn']}.key \
				-passout pass:#{node['srr_jenkins']['ssl']['keypassword']} 2048


			echo --> Generate the CSR <--
			openssl req \
				-new \
				-batch \
				-subj "/C=#{node['srr_jenkins']['ssl']['country']}/ST=#{node['srr_jenkins']['ssl']['state']}/localityName=#{node['srr_jenkins']['ssl']['locality']}/O=#{node['srr_jenkins']['ssl']['organization']}/organizationalUnitName=#{node['srr_jenkins']['ssl']['unit']}/commonName=#{node['fqdn']}/emailAddress=#{node['srr_jenkins']['ssl']['email']}/" \
				-key #{node['srr_jenkins']['ssl']['sslfilepath']}/#{node['fqdn']}.key \
				-out #{node['srr_jenkins']['ssl']['sslfilepath']}/#{node['fqdn']}.csr \
				-passin pass:#{node['srr_jenkins']['ssl']['keypassword']}

			echo --> Generate the cert good for 10 years <--
			openssl x509 \
				-req \
				-days 3650 \
				-in #{node['srr_jenkins']['ssl']['sslfilepath']}/#{node['fqdn']}.csr \
				-signkey #{node['srr_jenkins']['ssl']['sslfilepath']}/#{node['fqdn']}.key \
				-out #{node['srr_jenkins']['ssl']['sslfilepath']}/#{node['fqdn']}.crt \
				-passin pass:#{node['srr_jenkins']['ssl']['keypassword']}

			echo --> Make a p12 file <--
			openssl pkcs12 \
				-inkey #{node['srr_jenkins']['ssl']['sslfilepath']}/#{node['fqdn']}.key \
				-passin pass:#{node['srr_jenkins']['ssl']['keypassword']} \
				-in #{node['srr_jenkins']['ssl']['sslfilepath']}/#{node['fqdn']}.crt  \
				-export \
				-out #{node['srr_jenkins']['ssl']['sslfilepath']}/#{node['fqdn']}.pkcs12 \
				-password pass:#{node['srr_jenkins']['ssl']['storepassword']}

			echo --> Make a jks file <--
			#{node['jdk']['installroot']}/latest/bin/keytool -importkeystore \
			-srckeystore #{node['srr_jenkins']['ssl']['sslfilepath']}/#{node['fqdn']}.pkcs12 \
			-srcstoretype pkcs12 \
			-destkeystore #{node['srr_jenkins']['ssl']['sslfilepath']}/#{node['fqdn']}.jks \
			-srcstorepass #{node['srr_jenkins']['ssl']['storepassword']} \
			-deststorepass #{node['srr_jenkins']['ssl']['storepassword']}
		EOS
		notifies :restart, 'service[jenkins]'
		not_if { File.exist?("#{node['srr_jenkins']['ssl']['sslfilepath']}/#{node['fqdn']}.jks") }
	end
end
#END if SSL = TRUE


template "/etc/sysconfig/jenkins" do
	source "sysconfig-jenkins.erb"
	mode '0600'
	owner 'root'
	group 'root'
	notifies :restart, 'service[jenkins]'
end


template "/etc/init.d/jenkins" do
	source "jenkins_init.erb"
	mode '0755'
	owner 'root'
	group 'root'
	notifies :restart, 'service[jenkins]'
end



#setup the jenkins service
service "jenkins" do
	action [ :enable, :start ]
end


#give deploy sudo privs
template "/etc/sudoers.d/deploy-all" do
  source "deploy-all_sudo.erb"
  mode '0440'
  variables ({
	:deploy_user => node[:srr_deploy][:user]
  })
  only_if "getent passwd #{node[:srr_deploy][:user]}"
end
