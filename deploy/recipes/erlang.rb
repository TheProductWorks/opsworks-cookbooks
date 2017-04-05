include_recipe 'deploy'

node[:deploy].each do |application, deploy|
  if deploy[:application_type] != 'erlang'
    Chef::Log.info("Skipping deploy::erlang application #{application} as it is not an Erlang app")
    next
  end

  directory "/usr/local/#{application}" do
    owner deploy[:user]
    group deploy[:group]
    mode '0755'
    action :create

    not_if do
      File.exists?("/usr/local/#{application}")
    end
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

  execute 'Generate and compile release' do
    user deploy[:user]
    cwd deploy[:current_path]
    environment 'HOME' => '/home/deploy'
    command "rebar3 as prod release -o /usr/local/tp_api"
    action :run

    only_if do
      File.exists?(deploy[:current_path])
    end
  end

  include_recipe "deploy::erlang-restart"
end
