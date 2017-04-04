#
# Cookbook Name:: python
# Recipe:: default
#

package "python3.6" do
  retries 3
  retry_delay 5
end
