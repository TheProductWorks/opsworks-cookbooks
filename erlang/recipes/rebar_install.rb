#
# Install Rebar using the git repo.
#

bash 'install-rebar' do
  Chef::Log.info('Installing Rebar')

  code <<-EOH
    git clone git://github.com/rebar/rebar.git
    (cd rebar && ./bootstrap)
    cd ..
    mv rebar /usr/lib/
    ln -s /usr/lib/rebar /usr/bin/rebar
  EOH

  Chef::Log.info('Rebar successfully installed')
end

# link "/usr/lib/rebar" do
#   to "/usr/lib/rebar/rebar"
# end
