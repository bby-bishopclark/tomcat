# I can has java 7?
chef_gem "nexus_cli"
node.default['java']['jdk_version'] = 7
include_recipe "java"

yum_package node['tomcat']['package'] do
	action :install
end

remote_file "#{node['tomcat']['bin_dir']}/catalina-jmx-remote.jar" do
	source  node['tomcat']['extras']['jmx_url']
	only_if { node['tomcat']['extras']['jmx'] }
end
remote_file "#{node['tomcat']['bin_dir']}/catalina-ws.jar" do
	source  node['tomcat']['extras']['web_url']
	only_if { node['tomcat']['extras']['web'] }
end
remote_file "#{node['tomcat']['bin_dir']}/tomcat-juli-adapters.jar" do
	source  node['tomcat']['extras']['juli_url']
	only_if { node['tomcat']['extras']['juli'] }
end
remote_file "#{node['tomcat']['bin_dir']}/tomcat-juli.jar" do
	source  node['tomcat']['extras']['log4j_url']
	only_if { node['tomcat']['extras']['log4j'] }
end

template "#{node['tomcat']['config_dir']}/server.xml" do
	source "server.xml.erb"
  owner		node['tomcat']['user']
  group		node['tomcat']['group']
	mode 0440
	variables ({
		:shutdown_port 	=> node['tomcat']['shutdown_port'],
		:port 		=> node['tomcat']['port'],
		:proxy_port 	=> node['tomcat']['proxy_port'],
		:max_threads 	=> node['tomcat']['max_threads'],
                :globalrez	=> node['tomcat']['globalrez'],
                :connectors	=> node['tomcat']['connectors'],
		:valves		=> node['tomcat']['valves']
		})
	action :create
	notifies :restart, "service[#{node['tomcat']['service']}]"
end

template "#{node['tomcat']['config_dir']}/tomcat-users.xml" do
  owner		node['tomcat']['user']
  group		node['tomcat']['group']
	mode 0440
#  mode 0664
  variables ({
               :roles		=> node['tomcat']['roles'],
               :users		=> node['tomcat']['users']
             })
  action	:create
  notifies	:restart, "service[#{node['tomcat']['service']}]"
end

template "/etc/sysconfig/#{node['tomcat']['service']}" do
	source "tomcat.erb"
	mode 0664
	variables ({
		  :home 		=> node['tomcat']['home'],
		  :base 		=> node['tomcat']['base'],
		  :user 		=> node['tomcat']['user'],
		  :tmp_dir		=> node['tomcat']['tmp_dir'],
		  :java_options 	=> node['tomcat']['java_options'],
		  :catalina_options 	=> node['tomcat']['catalina_options'],
		  :endorsed_dir 	=> node['tomcat']['endorsed_dir']
		})
	action :create
	notifies :restart, "service[#{node['tomcat']['service']}]"
end

node['tomcat']['libs'].each do |lib|
	remote_file "#{node['tomcat']['lib_dir']}/#{lib['artifactId']}-#{lib['version']}.#{lib['packaging']}" do
		source Nexus.download_url(node['tomcat']['nexus'], lib['groupId'], lib['artifactId'], lib['packaging'], lib['version'], lib['repository'])
	end
end

service node['tomcat']['service'] do
	action 	[ :enable, :start ]
end
