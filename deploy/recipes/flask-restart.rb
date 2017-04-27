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
    pids_file = "#{deploy[:deploy_to]}/shared/pids/gunicorn"
    logs_file = "#{deploy[:deploy_to]}/shared/log/gunicorn.log"
    if deploy["gunicorn"]
      port = deploy["gunicorn"]["port"]
      workers = deploy["gunicorn"]["workers"]
    end
    # Defaults for port and worker count
    port ||= 8000
    workers ||= 4

    command "python_env/bin/gunicorn --workers #{workers} reporting:app --daemon --pid #{pids_file} --error-logfile #{logs_file} --bind :#{port}"
    action :run

    only_if do
      Dir.exists?(deploy[:current_path])
    end
  end
end


