#
# Cookbook Name:: deploy
# Recipe:: erlang-restart
#

include_recipe "deploy"

node[:deploy].each do |application, deploy|
  if deploy[:application_type] != 'erlang'
    Chef::Log.debug("Skipping deploy::erlang application #{application} as it is not an Erlang app")
    next
  end

  execute "restart Server" do
    user deploy[:user]
    command "/usr/local/tp_api/tp_api/bin/tp_api restart"
    action :run

    only_if do
      File.exists?(deploy[:current_path])
    end
  end

end


