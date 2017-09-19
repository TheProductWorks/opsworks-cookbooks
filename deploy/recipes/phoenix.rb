include_recipe 'deploy'

node[:deploy].each do |application, deploy|
  if deploy["application_type"] != 'elixir'
    Chef::Log.info("Skipping deploy::phoenix application #{application} as it is not a Phoenix app")
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
    environment 'MIX_HOME' => '/home/deploy/.mix', 'HEX_HOME' => '/home/deploy/.hex', 'HOME' => '/home/deploy'
    command "mix local.hex --force && mix local.rebar --force && mix deps.get --only prod"
    action :run
  end

  execute 'Compile' do
    user 'deploy'
    cwd deploy[:current_path]
    environment 'MIX_HOME' => '/home/deploy/.mix', 'MIX_ENV' => 'prod', 'HEX_HOME' => '/home/deploy/.hex', 'HOME' => '/home/deploy'
    command "MIX_ENV=prod mix compile"
    action :run
  end

  execute 'Digest' do
    user 'deploy'
    cwd deploy[:current_path]
    environment 'MIX_HOME' => '/home/deploy/.mix', 'MIX_ENV' => 'prod', 'HEX_HOME' => '/home/deploy/.hex', 'HOME' => '/home/deploy'
    command "MIX_ENV=prod mix phoenix.digest"
    action :run
  end

  execute 'Make the release' do
    user 'deploy'
    cwd deploy[:current_path]
    environment 'MIX_HOME' => '/home/deploy/.mix', 'MIX_ENV' => 'prod', 'HEX_HOME' => '/home/deploy/.hex', 'HOME' => '/home/deploy'
    command "MIX_ENV=prod mix release"
    action :run
  end

  directory "/usr/local/tp_api/#{application}" do
    owner deploy[:user]
    group deploy[:group]
    mode '0755'
    action :create

    not_if do
      File.exists?("/usr/local/tp_api/#{application}")
    end
  end

  execute "copy_release erts-7.3" do
    command "cp -r #{deploy[:current_path]}/rel/tp_phoenix/erts-7.3 /usr/local/tp_api/#{application}/"
    user "deploy"

    not_if do
      File.exists?("/usr/local/tp_api/#{application}/erts-7.3")
    end
  end

  execute "copy_release bin" do
    command "cp -r #{deploy[:current_path]}/rel/tp_phoenix/bin /usr/local/tp_api/#{application}/"
    user "deploy"
  end

  execute "copy_release lib" do
    command "cp -r #{deploy[:current_path]}/rel/tp_phoenix/lib /usr/local/tp_api/#{application}/"
    user "deploy"
  end

  execute "copy_release releases" do
    command "cp -r #{deploy[:current_path]}/rel/tp_phoenix/releases /usr/local/tp_api/#{application}/"
    user "deploy"
  end

  include_recipe "deploy::phoenix-restart"
end
