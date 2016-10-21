include_recipe 'deploy'

node[:deploy].each do |application, deploy|
  if deploy[:application_type] != 'elixir'
    Chef::Log.debug("Skipping deploy::erlang application #{application} as it is not a Phoenix app")
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

  bash 'build the app' do
    user 'deploy'
    cwd deploy[:current_path]
    code <<-EOH
      mix local.rebar --force
      mix local.hex --force
      mix deps.get --only prod
      MIX_ENV=prod mix compile
      MIX_ENV=prod mix phoenix.digest
      MIX_ENV=prod mix release
    EOH
    # mix generate
    #  - TODO make it run as the executable
    #  start the node:
    #  deploy[:current_path]/rel/tp_phoenix/bin/tp_phoenix start
    #  deploy[:current_path]/rel/tp_phoenix/bin/tp_phoenix stop
  end
end
