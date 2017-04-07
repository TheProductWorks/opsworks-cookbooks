include_recipe 'deploy'

node[:deploy].each do |application, deploy|
  if deploy[:application_type] != 'flask'
    Chef::Log.info("Skipping deploy::flask application #{application} as it is not a Flask app")
    next
  end

  opsworks_deploy_dir do
    user deploy[:user]
    group deploy[:group]
    path deploy[:deploy_to]
  end

  opsworks_deploy do
    deploy_data deploy
    app application
  end

  execute "install-new-virtual-env" do
    Chef::Log.info("Executing install-new-virtual-env")
    user deploy[:user]
    cwd deploy[:current_path]
    environment 'HOME' => '/home/deploy'
    command "virtualenv -p python3.6 python_env"
    action :run
    not_if do
      File.exists?("python_env")
    end
  end

  execute "install-requirements-txt" do
    Chef::Log.info("Executing install-requirements-txt")
    user deploy[:user]
    cwd deploy[:current_path]
    environment 'HOME' => '/home/deploy'
    command "python_env/bin/pip install -r requirements.txt"
    action :run
  end

  directory "#{deploy[:deploy_to]}/shared/pids" do
    owner deploy[:user]
    group deploy[:group]
    mode '0755'
    action :create
    not_if do
      File.exists?("#{deploy[:deploy_to]}/shared/pids")
    end
  end

  directory "#{deploy[:deploy_to]}/shared/logs" do
    owner deploy[:user]
    group deploy[:group]
    mode '0755'
    action :create
    not_if do
      File.exists?("#{deploy[:deploy_to]}/shared/logs")
    end
  end

  include_recipe "deploy::flask-restart"
end
