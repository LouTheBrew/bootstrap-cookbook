require 'poise'
require 'chef/resource'
require 'chef/provider'

module Bootstrap
  class Resource < Chef::Resource
    include Poise
    provides  :bootstrap
    actions   :go, :download, :delete
    attribute :name, name_attribute: true, kind_of: String
    attribute :fqdn, kind_of: String, required: true
    attribute :knife_pem_str, kind_of: String, required: true
    attribute :knife_pem_file, kind_of: String, required: true
    attribute :knife_config_file, kind_of: String, required: true
    attribute :client_config_file, kind_of: String, required: true
    attribute :client_pem_file, kind_of: String, required: true
    attribute :client_pem_str, kind_of: String, required: true
    attribute :client_log_file, kind_of: String, required: true
    attribute :first_run_file, kind_of: String, required: true
    attribute :validator_pem_str, kind_of: String, required: true
    attribute :validator_name, kind_of: String, required: true
    attribute :validator_file, kind_of: String, required: true
    attribute :chef_conf_dir, kind_of: String, required: true
    attribute :chef_log_dir, kind_of: String, required: true
    attribute :databag_key_str, kind_of: String, required: true
    attribute :databag_file, kind_of: String, required: true
    attribute :chef_server_url, kind_of: String, required: true
    attribute :chef_environment, kind_of: String, required: true
    attribute :run_list, kind_of: String, required: true
  end
  class Provider < Chef::Provider
    include Poise
    provides :bootstrap
    def go(conf)
      conf.each do |thing|
        thing[:directories].each do |dir|
          directory dir[:name] do
            recursive true
          end
        end
        thing[:templates].each do |tmp|
          template tmp[:name] do
            source tmp[:source]
            variables :context => tmp[:vars]
          end
        end
        thing[:commands].each do |cmd|
          bash cmd[:name] do
            cwd cmd[:dir]
            code <<-EOH
            #{cmd[:string]}
            EOH
          end
        end
      end
    end
    def action_go
      go([
          {
            :templates => [
              {
                :name => "#{new_resource.chef_conf_dir}#{new_resource.first_run_file}",
                :source => "#{new_resource.first_run_file}.erb",
                :vars => {
                  :run_list => new_resource.run_list
                }
              },
              {
                :name => "#{new_resource.chef_conf_dir}#{new_resource.validator_file}",
                :source => "#{new_resource.validator_file}.erb",
                :vars => {
                  :key => new_resource.validator_pem_str
                }
              },
              {
                :name => "#{new_resource.chef_conf_dir}#{new_resource.knife_config_file}",
                :source => "#{new_resource.knife_config_file}.erb",
                :vars => {
                  :key => new_resource.knife_pem_str
                }
              },
              {
                :name => "#{new_resource.chef_conf_dir}#{new_resource.client_config_file}",
                :source => "#{new_resource.client_config_file}.erb",
                :vars => {
                  :key => new_resource.client_pem_str
                }
              },
              {
                :name => new_resource.databag_file,
                :source => 'dbkey.erb',
                :vars => {
                  :key => new_resource.databag_key_str
                }
              },
              {
                :name => '/tmp/delete',
                :source => 'delete.erb',
                :vars => {
                  :name => new_resource.fqdn,
                  :knife => {
                    :config => {
                      :file => new_resource.knife_config_file
                    }
                  }
                }
              },
              {
                :name => '/tmp/client',
                :source => 'client.erb',
                :vars => {
                  :json => "#{new_resource.chef_conf_dir}#{new_resource.first_run_file}",
                  :environment => new_resource.chef_environment
                }
              },
              {
                :name => "#{new_resource.chef_conf_dir}#{new_resource.knife_config_file}",
                :source => "#{new_resource.knife_config_file}.erb",
                :vars => {
                  :log_location => "#{new_resource.chef_log_dir}#{new_resource.client_log_file}",
                  :node_name => new_resource.fqdn,
                  :client_key => "#{new_resource.chef_conf_dir}#{new_resource.client_pem_file}",
                  :chef_server_url => new_resource.chef_server_url,
                  :validation_client_name => new_resource.validator_name,
                  :validation_key => "#{new_resource.chef_conf_dir}#{new_resource.validator_file}",
                  :validation_client_key => "#{new_resource.chef_conf_dir}#{new_resource.validator_file}"
                }
              },
              {
                :name => "#{new_resource.chef_conf_dir}#{new_resource.client_config_file}",
                :source => "#{new_resource.client_config_file}.erb",
                :vars => {
                  :log_location => "#{new_resource.chef_log_dir}#{new_resource.client_log_file}",
                  :chef_server_url => new_resource.chef_server_url,
                  :validation_client_name => new_resource.validator_name,
                  :validation_key => "#{new_resource.chef_conf_dir}#{new_resource.validator_file}",
                  :validation_client_key => "#{new_resource.chef_conf_dir}#{new_resource.validator_file}"
                }
              }
            ],
            :directories => [
              {
                :name => new_resource.chef_conf_dir
              },
              {
                :name => new_resource.chef_log_dir
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
        ])
    end
  end
end
