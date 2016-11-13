include_recipe 'deploy'

node[:deploy].each do |application, deploy|
  if deploy[:application_type] != 'erlang'
    Chef::Log.debug("Skipping deploy::erlang application #{application} as it is not an PHP app")
    next
  end

  opsworks_deploy_dir do
    user deploy[:user]
    group deploy[:group]
    path deploy[:deploy_to]
  end

  execute 'build the release' do
    user 'deploy'
    cwd deploy[:release_path]
    command 'make release'
    action :run

    # rebar generate
    #  - TODO make it run as the executable
    #  start the node:
    #  deploy[:current_path]/rel/tp_api/bin/tp_api start
    #  deploy[:current_path]/rel/tp_api/bin/tp_api stop
  end

  opsworks_deploy do
    deploy_data deploy
    app application
  end
end
