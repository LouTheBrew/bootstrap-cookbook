include_recipe 'hostname'
bootstrap node[:set_fqdn] do
  knife_pem_file  node[:bootstrap][:knife][:key][:file]
  knife_config_file  node[:bootstrap][:knife][:config]
  knife_config_dir  node[:bootstrap][:knife][:dir]
  knife_user  node[:bootstrap][:knife][:user]
  client_config_file  node[:bootstrap][:client][:config][:file]
  client_pem_file  node[:bootstrap][:client][:pem][:file]
  client_pem_str  node[:bootstrap][:client][:pem][:str]
  client_log_file  node[:bootstrap][:client][:log][:file]
  first_run_file  node[:bootstrap][:json][:file]
  validator_pem_str  node[:bootstrap][:validator][:pem][:str]
  validator_name  node[:bootstrap][:validator][:name]
  validator_file  node[:bootstrap][:validator][:file]
  chef_conf_dir  node[:bootstrap][:dir][:conf]
  chef_log_dir  node[:bootstrap][:dir][:log]
  databag_key_str  node[:bootstrap][:databag][:key][:str]
  databag_file  node[:bootstrap][:databag][:key][:file]
  chef_server_url  node[:bootstrap][:server][:url]
  chef_environment  node[:bootstrap][:environment]
  run_list  node[:bootstrap][:run_list]
  fqdn "#{node[:bootstrap][:hostname]}#{node[:bootstrap][:domain]}"
end
