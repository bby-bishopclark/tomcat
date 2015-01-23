require 'spec_helper'

describe package('java-1.7.0-openjdk') do
	it { should be_installed }
end

describe package('java-1.7.0-openjdk-devel') do
	it { should be_installed }
end

describe package('tomcat') do
	it { should be_installed }
end

describe command('/opt/chef/embedded/bin/gem list --local | grep -iw -- ^nexus_cli | awk \'{print $1}\'') do
	its(:stdout) { should match /nexus_cli/ }
end

describe service('tomcat') do
	it { should be_running }
	it { should be_enabled }
end

describe file('/usr/share/tomcat/bin/catalina-jmx-remote.jar') do
	it { should be_file }
end

describe file('/usr/share/tomcat/bin/catalina-ws.jar') do
        it { should be_file }
end 

describe file('/usr/share/tomcat/bin/tomcat-juli-adapters.jar') do
        it { should be_file }
end 

describe file('/usr/share/tomcat/bin/tomcat-juli.jar') do
        it { should be_file }
end

describe file('/usr/share/tomcat/lib/logback-core-1.1.2.jar') do
        it { should be_file }
end

describe file('/usr/share/tomcat/lib/logback-access-1.1.2.jar') do
        it { should be_file }
end 

