# if you change this in a later override, you will need to change the hash first:
#    newport=9007
#    default['tomcat']['connectors'][newport] = node['tomcat']['connectors'][node['tomcat']['port']]
#    default['tomcat']['connectors'].delete(node['tomcat']['port'])
#    default['tomcat']['port'] = newport

default['tomcat']['port'] 		= 8080

default['tomcat']['proxy_port'] 	= nil
default['tomcat']['max_threads'] 	= nil	# default 200
default['tomcat']['ssl_proxy_port'] 	= nil
default['tomcat']['shutdown_port'] 	= 8005
default['tomcat']['catalina_options'] 	= ''
default['tomcat']['java_options'] 	= '-Xmx128M -Djava.awt.headless=true'
default['tomcat']['nexus'] 		= ''
default['tomcat']['extras']['jmx']	= false
default['tomcat']['extras']['web']	= false
default['tomcat']['extras']['juli']	= true
default['tomcat']['extras']['log4j']	= true
default['tomcat']['extras']['jmx_url']	= 'http://apache.osuosl.org/tomcat/tomcat-7/v7.0.57/bin/extras/catalina-jmx-remote.jar'
default['tomcat']['extras']['web_url']	= 'http://apache.osuosl.org/tomcat/tomcat-7/v7.0.57/bin/extras/catalina-ws.jar'
default['tomcat']['extras']['juli_url']	= 'http://apache.osuosl.org/tomcat/tomcat-7/v7.0.57/bin/extras/tomcat-juli-adapters.jar'
default['tomcat']['extras']['log4j_url']= 'http://apache.osuosl.org/tomcat/tomcat-7/v7.0.57/bin/extras/tomcat-juli.jar'
default['tomcat']['valves'] = [
				{
				  "className"	 => 'org.apache.catalina.valves.AccessLogValve',
				  "directory"	 => 'logs',
				  "prefix" 	 => 'local_host_access_log.',
				  "suffix"	 => '.txt',
				  "pattern"	 => 'common',
				  "resolveHosts" => 'false'
				}
			]
default['tomcat']['libs'] = [
				{
				  "groupId" 	=> 'ch.qos.logback',
				  "artifactId" 	=> 'logback-access',
				  "version" 	=> '1.1.2',
				  "packaging" 	=> 'jar',
				  "repository" 	=> 'public'
				},
				{
                                  "groupId" 	=> 'ch.qos.logback',
                                  "artifactId" 	=> 'logback-core',
                                  "version" 	=> '1.1.2',
                                  "packaging" 	=> 'jar',
                                  "repository" 	=> 'public'
				},
				{
                                  "groupId" 	=> 'net.logstash.logback',
                                  "artifactId" 	=> 'logstash-logback-encoder',
                                  "version" 	=> '3.7-SNAPSHOT',
                                  "packaging" 	=> 'jar',
                                  "repository" 	=> 'public'
				}
			]

case "#{node['platform']}#{node['platform_version'].split('.')[0]}"
when 'redhat6',  /amazon.*/
	default['tomcat']['package'] 		= 'tomcat7'
	default['tomcat']['service'] 		= 'tomcat7'
	default['tomcat']['user'] 		= 'tomcat'
	default['tomcat']['group'] 		= 'tomcat'
	default['tomcat']['home'] 		= "/usr/share/tomcat7"
	default['tomcat']['base'] 		= "/usr/share/tomcat7"
	default['tomcat']['config_dir'] 	= "/etc/tomcat7"
	default['tomcat']['log_dir'] 		= "/var/log/tomcat7"
	default['tomcat']['tmp_dir'] 		= "/var/cache/tomcat7/temp"
	default['tomcat']['work_dir'] 		= "/var/cache/tomcat7/work"
	default['tomcat']['context_dir'] 	= "#{node['tomcat']['config_dir']}/Catalina/localhost"
	default['tomcat']['webapp_dir'] 	= "#{node['tomcat']['home']}/webapps"
	default['tomcat']['lib_dir'] 		= "#{node['tomcat']['home']}/lib"
	default['tomcat']['endorsed_dir'] 	= "#{node['tomcat']['lib_dir']}/endorsed"
else		# centos, redhat7, fedora
	default['tomcat']['package'] 		= 'tomcat'
	default['tomcat']['service'] 		= 'tomcat'	
	default['tomcat']['user'] 		= 'tomcat'
	default['tomcat']['group'] 		= 'tomcat'
	default['tomcat']['home'] 		= "/usr/share/tomcat"
	default['tomcat']['base'] 		= "/usr/share/tomcat"
	default['tomcat']['config_dir'] 	= "/etc/tomcat"
	default['tomcat']['log_dir'] 		= "/var/log/tomcat"
	default['tomcat']['tmp_dir'] 		= "/var/cache/tomcat/temp"
	default['tomcat']['work_dir'] 		= "/var/cache/tomcat/work"
	default['tomcat']['context_dir'] 	= "#{node['tomcat']['config_dir']}/Catalina/localhost"
	default['tomcat']['webapp_dir'] 	= "#{node['tomcat']['home']}/webapps"
	default['tomcat']['lib_dir'] 		= "#{node['tomcat']['home']}/lib"
	default['tomcat']['bin_dir']		= "#{node['tomcat']['home']}/bin"
	default['tomcat']['endorsed_dir'] 	= "#{node['tomcat']['lib_dir']}/endorsed"
end

# https://tomcat.apache.org/tomcat-8.0-doc/config/http.html
# set some defaults for newer template system, based on values above.
default['tomcat']['connectors'] = {
  node['tomcat']['port'] => {
    "connectionTimeout" => "20000",
    "proxy_port" => node['tomcat']['proxy_port'],
    "max_threads" => node['tomcat']['max_threads'],
    "URIEncoding" => "UTF-8"
  }
}


default['tomcat']['roles'] = [
                              "tomcat",
                              "role1",
                              "admin",
                              "admin-gui",
                              "admin-script",
                              "manager",
                              "manager-gui",
                              "manager-script",
                              "manager-jmx",
                              "manager-status",
                              ]


default['tomcat']['globalrez']['resources'] = {
  "UserDatabase" => {
    'comment' => "Editable user database that can also be used by UserDatabaseRealm to authenticate users",
    'auth' => "Container",
    'type' => "org.apache.catalina.UserDatabase",
    'description' => "User database that can be updated and saved",
    'factory' => "org.apache.catalina.users.MemoryUserDatabaseFactory",
    'pathname' => "conf/tomcat-users.xml"
  }
}


# this is temporary:
# - end users should have a vault set up 
# - we need the vault-or-ghetto switch for data here
# - per-host over-rides anyway, which should be crypto-dbags or vault
# I KNOW the per-host creds will kill this code bit.  I know it.
default['tomcat']['users'] = {
  "tomcat" => {
    "password"  => "changeme",
    "roles"   	=> "tomcat"
  },
  "role1" => {
    "password"  => "changeme",
    "roles"	=> "role1"
  }, 
  "both" => {
    "password"  => "changeme",
    "roles"   	=> "tomcat,role1" # arrays are ghetto for now; fix later
  },
  "manager" => {
    "password" => "s3cret",
    "roles" => "manager-gui"
  }
}


