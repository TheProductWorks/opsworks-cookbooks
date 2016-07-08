#
# Install Rebar using the git repo.
#

bash 'install-rebar' do
  Chef::Log.info('Installing Rebar')
  user 'root'
  cwd '/usr/lib'

  code <<-EOH
    git clone git://github.com/rebar/rebar.git
    (cd rebar && ./bootstrap)
    ln -s /usr/lib/rebar/rebar /usr/bin/rebar
  EOH

  Chef::Log.info('Rebar successfully installed')
end

# link "/usr/lib/rebar" do
#   to "/usr/lib/rebar/rebar"
# end
