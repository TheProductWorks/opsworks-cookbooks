#
# Cookbook Name:: deploy
# Recipe:: flask-restart
#

include_recipe "deploy"

node[:deploy].each do |application, deploy, gunicorn_processes|
  if deploy[:application_type] != 'flask'
    Chef::Log.info("Skipping deploy::flask application #{application} as it is not a Flask app")
    next
  end

  execute "stop-reporting-service" do
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

  end

  execute "start-reporting-service" do
    timeout 180
    user deploy[:user]
    cwd deploy[:current_path]
    environment 'HOME' => '/home/deploy'
    pids_file = "#{deploy[:deploy_to]}/shared/pids/gunicorn"

    command "sleep 1"

    # command "python_env/bin/gunicorn --workers 4 reporting:app --daemon --pid #{pids_file} --error-logfile ./logs/gunicorn_error"
    action :run

    only_if do
      File.exists?(deploy[:current_path])
    end
  end
end


