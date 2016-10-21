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

  # Set the mix home env
  sys_env_file = Chef::Util::FileEdit.new('/etc/environment')
  deploy['environment'].each do |name, val|
    sys_env_file.insert_line_if_no_match(/^#{name}\=/, "#{name}=\"#{val}\"")
    sys_env_file.write_file
  end

  # use template 'prod.secret.exs.erb' to generate 'config/prod.secret.exs'
  template "#{deploy[:current_path]}/config/prod.secret.exs" do
    source "prod.secret.exs.erb"

    # set mode, group and owner of generated file
    mode "0660"
    group deploy[:group]
    owner deploy[:user]
  end

  execute 'Get dependencies' do
    user 'deploy'
    cwd deploy[:current_path]
    environment 'MIX_HOME' => '/home/deploy/.mix', 'HEX_HOME' => '/home/deploy/.hex'
    command "mix local.hex --force && mix local.rebar --force && mix deps.get --only prod"
    action :run
  end
=begin
  execute 'Compile' do
    user 'deploy'
    cwd deploy[:current_path]
    environment 'MIX_HOME' => '/home/deploy/.mix', 'MIX_ENV' => 'prod', 'HEX_HOME' => '/home/deploy/.hex'
    command "mix compile"
    action :run
  end

  execute 'Digest' do
    user 'deploy'
    cwd deploy[:current_path]
    environment 'MIX_HOME' => '/home/deploy/.mix', 'MIX_ENV' => 'prod', 'HEX_HOME' => '/home/deploy/.hex'
    command "mix phoenix.digest"
    action :run
  end

  execute 'Make the release' do
    user 'deploy'
    cwd deploy[:current_path]
    environment 'MIX_HOME' => '/home/deploy/.mix', 'MIX_ENV' => 'prod', 'HEX_HOME' => '/home/deploy/.hex'
    command "mix release"
    action :run
  end
=end
  # mix release
  #  start the node:
  #  deploy[:current_path]/rel/tp_phoenix/bin/tp_phoenix start
  #  deploy[:current_path]/rel/tp_phoenix/bin/tp_phoenix stop
end
