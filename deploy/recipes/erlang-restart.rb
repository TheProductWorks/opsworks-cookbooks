#
# Cookbook Name:: deploy
# Recipe:: erlang-restart
#

include_recipe "deploy"

node[:deploy].each do |application, deploy|
  if deploy[:application_type] != 'erlang'
    Chef::Log.info("Skipping deploy::erlang application #{application} as it is not an Erlang app")
    next
  end

  # RESTART the server, if already started
  execute "restart Server" do
    user deploy[:user]
    cwd deploy[:current_path]
    environment 'HOME' => '/home/deploy'
    command "/usr/local/tp_api/tp_api/bin/tp_api restart"
    action :run

    only_if do
      system('/usr/local/tp_api/tp_api/bin/tp_api ping')
    end
  end

  # START the server, if not already started
  execute "start Server" do
    user deploy[:user]
    cwd deploy[:current_path]
    environment 'HOME' => '/home/deploy'
    command "/usr/local/tp_api/tp_api/bin/tp_api start"
    action :run

    not_if do
      system('/usr/local/tp_api/tp_api/bin/tp_api ping')
    end
  end

end


