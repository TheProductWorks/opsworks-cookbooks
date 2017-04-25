# stop gunicorn service per app
node[:deploy].each do |application, deploy|
  if deploy[:application_type] != 'flask'
    Chef::Log.debug("Skipping gunicorn::flask application #{application} as it is not a Flask app")
    next
  end

  execute "stop gunicorn" do
    pids_file = "#{deploy[:deploy_to]}/shared/pids/gunicorn"
    command "kill -s TERM $(head -n 1 #{pids_file})"

    only_if do
      File.exists?("#{deploy[:deploy_to]}/shared/pids/gunicorn")
    end
  end
end
