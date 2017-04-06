include_recipe "deploy"

node[:deploy].each do |application, deploy, gunicorn_processes|
  if deploy[:application_type] != 'flask'
    Chef::Log.info("Skipping deploy::flask application #{application} as it is not a Flask app")
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

  end

  include_recipe "deploy::flask-start"
end


