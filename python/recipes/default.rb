#
# Cookbook Name:: python
# Recipe:: default
#

# apt_repository 'ppa:jonathonf' do
#   uri 'https://launchpad.net/~jonathonf/+archive/ubuntu/python-3.6'
# end

execute "add-apt-repository-jonathonf-python-3.6" do
  command "add-apt-repository ppa:jonathonf/python-3.6"
end

package "python3.6" do
  action :install
  retries 3
  retry_delay 5
end
