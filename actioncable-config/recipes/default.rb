node[:deploy].each do |app_name, deploy_config|
  if deploy[:application_type] != 'rails'
    Chef::Log.info("Skipping actioncable-config application #{application} as it is not a Rails app")
    next
  end

  # determine root folder of new app deployment
  app_root = "#{deploy_config[:deploy_to]}/current"

  # use template 'cable.yml.erb' to generate 'config/cable.yml'
  template "#{app_root}/config/cable.yml" do
    source "cable.yml.erb"
    cookbook "actioncable-config"

    # set mode, group and owner of generated file
    mode "0660"
    group deploy_config[:group]
    owner deploy_config[:user]

    # define variable “@cable” to be used in the ERB template
    variables(
      :cable => deploy_config[:cable] || {}
    )

    # only generate a file if there is cable configuration
    not_if do
      deploy_config[:cable].blank?
    end
  end
end

