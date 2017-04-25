include_recipe "nginx"
include_recipe "gunicorn"

# setup Unicorn service per app
node[:deploy].each do |application, deploy|
  if deploy[:application_type] != 'flask'
    Chef::Log.debug("Skipping gunicorn::flask application #{application} as it is not a Flask app")
    next
  end

  opsworks_deploy_user do
    deploy_data deploy
  end

  opsworks_deploy_dir do
    user deploy[:user]
    group deploy[:group]
    path deploy[:deploy_to]
  end

=begin
  # Add template files for gunicorn here

  template "#{deploy[:deploy_to]}/shared/scripts/unicorn" do
    mode '0755'
    owner deploy[:user]
    group deploy[:group]
    source "unicorn.service.erb"
    variables(:deploy => deploy, :application => application)
  end

  service "unicorn_#{application}" do
    start_command "#{deploy[:deploy_to]}/shared/scripts/unicorn start"
    stop_command "#{deploy[:deploy_to]}/shared/scripts/unicorn stop"
    restart_command "#{deploy[:deploy_to]}/shared/scripts/unicorn restart"
    status_command "#{deploy[:deploy_to]}/shared/scripts/unicorn status"
    action :nothing
  end

  template "#{deploy[:deploy_to]}/shared/config/unicorn.conf" do
    mode '0644'
    owner deploy[:user]
    group deploy[:group]
    source "unicorn.conf.erb"
    variables(
      :deploy => deploy,
      :application => application,
      :environment => OpsWorks::Escape.escape_double_quotes(deploy[:environment_variables])
    )
  end
=end

end
