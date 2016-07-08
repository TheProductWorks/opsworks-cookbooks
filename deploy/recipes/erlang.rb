include_recipe 'deploy'

node[:deploy].each do |application, deploy|

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
      rebar get-deps
      rebar compile
    EOH
    # rebar generate
    #  - TODO make it run as the executable
  end
end
