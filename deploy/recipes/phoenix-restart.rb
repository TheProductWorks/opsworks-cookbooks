#
# Cookbook Name:: deploy
# Recipe:: phoenix-restart
#

include_recipe "deploy"

node[:deploy].each do |application, deploy|
  if deploy[:application_type] != 'elixir'
    Chef::Log.info("Skipping deploy::pheonix application #{application} as it is not an Phoenix / Elixir app")
    next
  end

  execute "restart Server" do
    user deploy[:user]
    cwd deploy[:current_path]
    environment 'HOME' => '/home/deploy'
    command "/usr/local/tp_api/tp_phoenix/bin/tp_phoenix restart"
    action :run

    only_if do
      system "/usr/local/tp_api/tp_phoenix/bin/tp_phoenix ping"
    end
  end

end


