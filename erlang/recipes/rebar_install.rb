#
# Install Rebar using the git repo.
#

bash 'install-rebar' do
  Chef::Log.info('Installing Rebar')
  user 'root'
  cwd '/usr/local/src'

  code <<-EOH
    [ ! -d rebar ] && git clone git://github.com/rebar/rebar.git
    (cd rebar && ./bootstrap)
    ln -s /usr/local/src/rebar/rebar /usr/bin/rebar
  EOH

  Chef::Log.info('Rebar successfully installed')
  action :nothing
  not_if "rebar --version"
end

# link "/usr/lib/rebar" do
#   to "/usr/lib/rebar/rebar"
# end
