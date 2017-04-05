#
# Cookbook Name:: deploy
# Recipe:: flask-restart
#

include_recipe "deploy"

node[:deploy].each do |application, deploy|
  if deploy[:application_type] != 'tp_reporting'
    Chef::Log.info("application_type is #{deploy[:application_type]}")
    Chef::Log.info("Skipping deploy::flask application #{application} as it is not a Flask app")
    next
  end

  execute "restart reporting server" do
    user deploy[:user]
    cwd deploy[:current_path]
    environment 'HOME' => '/home/deploy'
    command "python_env/bin/gunicorn -w 4 reporting:app"
    action :run

    only_if do
      File.exists?(deploy[:current_path])
    end
  end
end


