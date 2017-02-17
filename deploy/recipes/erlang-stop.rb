#
# Cookbook Name:: deploy
# Recipe:: erlang-stop
#

include_recipe "deploy"

node[:deploy].each do |application, deploy|
  if deploy[:application_type] != 'erlang'
    Chef::Log.debug("Skipping deploy::erlang application #{application} as it is not an Erlang app")
    next
  end

  execute "stop Server" do
    user deploy[:user]
    environment 'HOME' => '/home/deploy'
    command "/usr/local/tp_api/tp_api/bin/tp_api stop"
    action :run

    only_if do
      File.exists?(deploy[:current_path])
    end
  end

end


