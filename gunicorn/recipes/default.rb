# TODO potentially add some checks here about gunicorn version
# see the unicorn::default recipe as example.
node[:deploy].each do |application, deploy|
  if deploy[:application_type] != 'flask'
    Chef::Log.debug("Skipping gunicorn::flask application #{application} as it is not a Flask app")
    next
  end

  template "#{deploy[:deploy_to]}/shared/config/gunicorn.conf" do
    mode '0644'
    owner deploy[:user]
    group deploy[:group]

    # Variables
    pids_file = "#{deploy[:deploy_to]}/shared/pids/gunicorn"
    logs_file = "#{deploy[:deploy_to]}/shared/log/gunicorn.log"
    if deploy["gunicorn"]
      port = deploy["gunicorn"]["port"]
      workers = deploy["gunicorn"]["workers"]
    end
    # Defaults for port and worker count
    port ||= 8000
    workers ||= 4

    source "gunicorn_conf.erb"
    variables(
      :deploy => deploy,
      :application => application,
      :port => port,
      :pids_file => pids_file,
      :logs_file => logs_file,
      :workers => workers,
      :environment => OpsWorks::Escape.escape_double_quotes(deploy[:environment_variables])
    )
  end
end
