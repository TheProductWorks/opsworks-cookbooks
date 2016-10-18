#
# Cookbook Name:: phoenix
# Recipe:: install_phoenix
#

execute "Install Hex for Elixir" do
  command "mix local.hex --force"
  action  :run
end

execute "Install Phoenix Framework" do
  command "mix archive.install #{node[:phoenix][:archive_url]} --force"
  action  :run
end
