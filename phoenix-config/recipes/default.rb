node[:deploy].each do |app_name, deploy_config|
  if deploy_config[:application_type] != 'elixir'
    Chef::Log.debug("Skipping setup config file #{app_name} as it is not a Phoenix app")
    next
  end

  # determine root folder of new app deployment
  app_root = "#{deploy_config[:deploy_to]}/current"

  # use template 'prod.secret.exs.erb' to generate 'config/prod.secret.exs'
  template "#{app_root}/config/prod.secret.exs" do
    source "prod.secret.exs.erb"
    cookbook "phoenix-config"

    # set mode, group and owner of generated file
    mode "0660"
    group deploy_config[:group]
    owner deploy_config[:user]
  end
end
