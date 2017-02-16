#
# Install Rebar using the git repo.
#

CWD='/usr/local/src'
REBAR_LOCATION="#{CWD}/rebar3"

git REBAR_LOCATION do
  Chef::Log.info('Cloning Rebar3 repo')
  repository 'git@github.com:erlang/rebar3.git'
  revision 'master'
  action :sync
  notifies :run, 'bash[compile_rebar3]', :immediately
end

bash 'compile_rebar3' do
  Chef::Log.info('Compiling Rebar3')
  cwd CWD
  user 'root'

  code <<-EOH
    (cd #{REBAR_LOCATION} && ./bootstrap)
  EOH

  action :nothing
  not_if "rebar3 --version"
  notifies :run, 'link[setup_rebar3_executable]', :immediately
end

link 'setup_rebar3_executable' do
  user 'root'

  target_file "/usr/bin/rebar3"
  Chef::Log.info('Linking Rebar3')
  to "#{REBAR_LOCATION}/rebar3"
end
