knife_pem_str = node[:bootstrap][:knife][:key][:str]
knife_pem_file = node[:bootstrap][:knife][:key][:file]
knife_config_file = node[:bootstrap][:knife][:config]
client_config_file = node[:bootstrap][:client][:config][:file]
client_pem_file = node[:bootstrap][:client][:pem][:file]
client_pem_str = node[:bootstrap][:client][:pem][:str]
client_log_file = node[:bootstrap][:client][:log][:file]
first_run_file = node[:bootstrap][:json][:file]
validator_pem_str = node[:bootstrap][:validator][:pem][:str]
validator_name = node[:bootstrap][:validator][:name]
validator_file = node[:bootstrap][:validator][:file]
chef_conf_dir = node[:bootstrap][:dir][:conf]
chef_log_dir = node[:bootstrap][:dir][:log]
databag_key_str = node[:bootstrap][:databag][:key][:str]
databag_file = node[:bootstrap][:databag][:key][:file]
chef_server_url = node[:bootstrap][:server][:url]
chef_environment = node[:bootstrap][:environment]
run_list = node[:bootstrap][:run_list]

include_recipe 'hostname'
bootstrap 'this_node' do
  config [
    {
      :templates => [
        {
          :name => "#{chef_conf_dir}#{first_run_file}",
          :source => "#{first_run_file}.erb",
          :vars => {
            :run_list => run_list
          }
        },
        {
          :name => "#{chef_conf_dir}#{validator_file}",
          :source => "#{validator_file}.erb",
          :vars => {
            :key => validator_pem_str
          }
        },
        {
          :name => "#{chef_conf_dir}#{knife_config_file}",
          :source => "#{knife_config_file}.erb",
          :vars => {
            :key => knife_pem_str
          }
        },
        {
          :name => "#{chef_conf_dir}#{client_config_file}",
          :source => "#{client_config_file}.erb",
          :vars => {
            :key => client_pem_str
          }
        },
        {
          :name => databag_file,
          :source => 'dbkey.erb',
          :vars => {
            :key => databag_key_str
          }
        },
        {
          :name => '/tmp/delete',
          :source => 'delete.erb',
          :vars => {
            :name => node[:set_fqdn],
            :knife => {
              :config => {
                :file => knife_config_file
              }
            }
          }
        },
        {
          :name => '/tmp/client',
          :source => 'client.erb',
          :vars => {
            :json => "#{chef_conf_dir}#{first_run_file}",
            :environment => chef_environment
          }
        },
        {
          :name => "#{chef_conf_dir}#{knife_config_file}",
          :source => "#{knife_config_file}.erb",
          :vars => {
            :log_location => "#{chef_log_dir}#{client_log_file}",
            :node_name => node[:set_fqdn],
            :client_key => "#{chef_conf_dir}#{client_pem_file}",
            :chef_server_url => chef_server_url,
            :validation_client_name => validator_name,
            :validation_key => "#{chef_conf_dir}#{validator_file}",
            :validation_client_key => "#{chef_conf_dir}#{validator_file}"
          }
        },
        {
          :name => "#{chef_conf_dir}#{client_config_file}",
          :source => "#{client_config_file}.erb",
          :vars => {
            :log_location => "#{chef_log_dir}#{client_log_file}",
            :chef_server_url => chef_server_url,
            :validation_client_name => validator_name,
            :validation_key => "#{chef_conf_dir}#{validator_file}",
            :validation_client_key => "#{chef_conf_dir}#{validator_file}"
          }
        }
      ],
      :directories => [
        {
          :name => chef_conf_dir
        },
        {
          :name => '/root/.ssh/'
        },
        {
          :name => chef_log_dir
        }
      ],
      :commands => [
        {
          :name => 'knife_delete',
          :dir => '/tmp/',
          :string => <<-EOH
          bash /tmp/delete
          EOH
        },
        {
          :name => 'chef_client',
          :dir => '/tmp/',
          :string => <<-EOH
          bash /tmp/client
          EOH
        }
      ]
    }
  ]
end
