
node[:deploy].each do |app_name, deploy_config|
  # determine root folder of new app deployment
  app_root = "#{deploy_config[:deploy_to]}/current"

  # use template '.env.erb' to generate 'config/.env'
  template "#{app_root}/.env" do
    source ".env.erb"
    cookbook "rails"

    # set mode, group and owner of generated file
    mode "0660"
    group deploy_config[:group]
    owner deploy_config[:user]

    # define variable “@secrets” to be used in the ERB template
    variables(
      :vars => deploy_config[:environment_variables] || {}
    )

    # only generate a file if there is secrets configuration
    not_if do
      deploy_config[:environment_variables].empty?
    end
  end
end
