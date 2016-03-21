default[:bootstrap][:happy] = nil
default[:bootstrap][:hostname] = nil
default[:bootstrap][:domain] = nil
default[:set_fqdn] = "#{default[:bootstrap][:hostname]}#{default[:bootstrap][:domain]}"
default[:bootstrap][:server][:url] = nil
default[:bootstrap][:environment] = nil
default[:bootstrap][:dir][:conf] = '/etc/chef/'
default[:bootstrap][:dir][:log] = '/var/log/chef/'
default[:bootstrap][:knife][:config] = 'knife.rb'
default[:bootstrap][:knife][:dir] = '/etc/chef/knife/'
default[:bootstrap][:knife][:user] = nil
default[:bootstrap][:knife][:key][:file] = 'knife.pem'
default[:bootstrap][:client][:config][:file] = 'client.rb'
default[:bootstrap][:client][:pem][:file] = 'client.pem'
default[:bootstrap][:client][:log][:file] = 'client.log'
default[:bootstrap][:client][:pem][:str] = nil
default[:bootstrap][:json][:file] = 'first-run.json'
default[:bootstrap][:validator][:file] = 'validator.pem'
default[:bootstrap][:validator][:pem][:str] = nil
default[:bootstrap][:validator][:name] = 'chef_validator'
default[:bootstrap][:databag][:key][:file] = nil
default[:bootstrap][:databag][:key][:str] = nil
default[:bootstrap][:run_list] = nil
