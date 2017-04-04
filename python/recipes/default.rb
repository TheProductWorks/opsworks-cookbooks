#
# Cookbook Name:: python
# Recipe:: default
#


execute "add-apt-repository-jonathonf-python-3.6" do
  command "add-apt-repository ppa:jonathonf/python-3.6"
end

execute "apt-get-update" do
  command "apt-get update"
end

package "python3.6" do
  action :install
  retries 3
  retry_delay 5
end
