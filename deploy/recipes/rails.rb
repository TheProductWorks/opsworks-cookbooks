include_recipe 'deploy'

node[:deploy].each do |application, deploy|

  if deploy[:application_type] != 'rails'
    Chef::Log.info("Skipping deploy::rails application #{application} as it is not a Rails app")
    next
  end

  case deploy[:database][:type]
  when "mysql"
    include_recipe "mysql::client_install"
  when "postgresql"
    include_recipe "opsworks_postgresql::client_install"
  end

  # Set the mix home env
  sys_env_file = Chef::Util::FileEdit.new('/etc/environment')
  deploy['environment'].each do |name, val|
    sys_env_file.insert_line_if_no_match(/^#{name}\=/, "#{name}=\"#{val}\"")
    sys_env_file.write_file
  end

  opsworks_deploy_dir do
    user deploy[:user]
    group deploy[:group]
    path deploy[:deploy_to]
  end

  opsworks_rails do
    deploy_data deploy
    app application
  end

  opsworks_deploy do
    deploy_data deploy
    app application
  end
end
