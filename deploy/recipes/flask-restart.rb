#
# Cookbook Name:: deploy
# Recipe:: flask-restart
#

include_recipe "deploy"

node[:deploy].each do |application, deploy, gunicorn_processes|
  if deploy[:application_type] != 'flask'
    Chef::Log.info("Skipping deploy::flask application #{application} as it is not a Flask app")
    next
  end

  execute "restart reporting server" do
    timeout 120
    user deploy[:user]
    cwd deploy[:current_path]
    environment 'HOME' => '/home/deploy'
    puts "node"
    puts node
    command "sleep 1"

    # command "python_env/bin/gunicorn -w 4 reporting:app"
    action :run

    only_if do
      File.exists?(deploy[:current_path])
    end
  end
end


