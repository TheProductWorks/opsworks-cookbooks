#
# Cookbook Name:: python
# Recipe:: default
#

apt_repository 'ppa:jonathonf' do
  uri 'https://launchpad.net/~jonathonf/+archive/ubuntu/python-3.6'
  action :add
end

package "python3.6" do
  retries 3
  retry_delay 5
end
