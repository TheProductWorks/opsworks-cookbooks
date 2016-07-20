
node[:deploy].each do |app_name, deploy_config|
  if deploy_config[:application_type] != 'rails'
    Chef::Log.debug("Skipping deploy::rails application #{app_name} as it is not a Rails app")
    next
  end

  # determine root folder of new app deployment
  app_root = "#{deploy_config[:deploy_to]}/current"

  # use template 'secrets.yml.erb' to generate 'config/secrets.yml'
  template "#{app_root}/config/secrets.yml" do
    source "secrets.yml.erb"
    cookbook "rails"

    # set mode, group and owner of generated file
    mode "0660"
    group deploy_config[:group]
    owner deploy_config[:user]

    # define variable “@secrets” to be used in the ERB template
    variables(
      :key_base => deploy_config[:environment_variables]["SECRET_KEY_BASE"] || ""
    )

    # only generate a file if there is secrets configuration
    not_if do
      deploy_config[:environment_variables]["SECRET_KEY_BASE"].blank?
    end
  end
end
