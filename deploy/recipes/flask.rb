include_recipe 'deploy'

node[:deploy].each do |application, deploy|
  if deploy[:application_type] != 'flask'
    Chef::Log.debug("Skipping deploy::flask application #{application} as it is not a Flask app")
    next
  end

  opsworks_deploy_dir do
    Chef::Log.info("Hello Mate")
    user deploy[:user]
    group deploy[:group]
    path deploy[:deploy_to]
  end

  opsworks_deploy do
    Chef::Log.info("Hello Mate 2")
    deploy_data deploy
    app application
  end

  execute "install-new-virtual-env" do
    Chef::Log.info("Hello Mate 3")
    user deploy[:user]
    cwd deploy[:current_path]
    environment 'HOME' => '/home/deploy'
    command "virtualenv -p python3.6 python_env"
    action :run
  end

  execute "install-requirements-txt" do
    Chef::Log.info("Hello Mate 4")
    user deploy[:user]
    cwd deploy[:current_path]
    environment 'HOME' => '/home/deploy'
    command "python_env/bin/pip install -r requirements.txt"
    action :run
  end

  include_recipe "deploy::flask-restart"
end
