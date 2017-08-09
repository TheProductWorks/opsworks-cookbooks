#
# Install Rebar using the git repo.
#

CWD='/usr/local/src'
REBAR_LOCATION="#{CWD}/rebar3"

execute 'install' do
  cwd CWD
  user 'root'
  command "wget https://s3.amazonaws.com/rebar3/rebar3"

  not_if "rebar3 --version"
end


link 'setup_rebar3_executable' do
  user 'root'

  target_file "/usr/bin/rebar3"
  Chef::Log.info('Linking Rebar3')
  to "#{REBAR_LOCATION}/rebar3"
end
