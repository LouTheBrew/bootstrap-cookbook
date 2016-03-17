require 'poise'
require 'chef/resource'
require 'chef/provider'

module Bootstrap
  class Resource < Chef::Resource
    include Poise
    provides  :bootstrap
    actions   :go, :download, :delete
    attribute :name, name_attribute: true, kind_of: String
    attribute :config, kind_of: Array, required: true
  end
  class Provider < Chef::Provider
    include Poise
    provides :bootstrap
    def action_go
      new_resource.config.each do |thing|
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
  end
end
