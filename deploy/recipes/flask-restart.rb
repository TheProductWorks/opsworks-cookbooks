#
# Cookbook Name:: deploy
# Recipe:: flask-restart
#

include_recipe "deploy"

node[:deploy].each do |application, deploy, gunicorn_processes|
  if deploy["application_type"] != 'flask'
    Chef::Log.info("Skipping deploy::flask-restart application #{application} as it is not a Flask app")
    next
  end

  include_recipe "gunicorn"

  execute "stop-reporting-service" do
    Chef::Log.info("Executing stop-reporting-service")
    timeout 180
    user deploy[:user]
    cwd deploy[:current_path]
    environment 'HOME' => '/home/deploy'
    pids_file = "#{deploy[:deploy_to]}/shared/pids/gunicorn"
    command "kill -s TERM $(head -n 1 #{pids_file})"
    action :run

    only_if do
      File.exists?("#{deploy[:deploy_to]}/shared/pids/gunicorn")
    end
    notifies :run, 'execute[start-reporting-service]', :immediately
  end

  execute "start-reporting-service" do
    Chef::Log.info("Executing start-reporting-service")
    timeout 180
    user deploy[:user]
    cwd deploy[:current_path]
    environment 'HOME' => '/home/deploy'
    config_file = "#{deploy[:deploy_to]}/shared/config/gunicorn.conf"

    command "python_env/bin/gunicorn -c #{config_file} reporting:app"
    action :run

    only_if do
      Dir.exists?(deploy[:current_path])
    end
  end
end


