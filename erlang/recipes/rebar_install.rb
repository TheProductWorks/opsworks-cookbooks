#
# Install Rebar using the git repo.
#

CWD='/usr/local/src'
REBAR_LOCATION="#{CWD}/rebar"

git REBAR_LOCATION do
  Chef::Log.info('Cloning Rebar repo')
  repository 'git@github.com:rebar/rebar.git'
  revision 'master'
  action :sync
  notifies :run, 'bash[compile_rebar]', :immediately
end

bash 'compile_rebar' do
  Chef::Log.info('Compiling Rebar')
  cwd CWD
  user 'root'

  code <<-EOH
    (cd #{REBAR_LOCATION} && ./bootstrap)
    ln -s /usr/local/src/rebar/rebar /usr/bin/rebar
  EOH

  action :nothing
  not_if "rebar --version"
  notifies :run, 'link[setup_rebar_executable]', :immediately
end

link 'setup_rebar_executable' do
  target_file "/usr/bin/rebar"
  Chef::Log.info('Linking Rebar')
  to "#{REBAR_LOCATION}/rebar"
end
