#
# Cookbook Name:: phoenix
# Recipe:: install_elixir
#
#

case node['platform']
when 'ubuntu', 'debian'
  execute "Setup erlang solutions as a package source" do
    command "wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && sudo dpkg -i erlang-solutions_1.0_all.deb"
    action  :run
  end

  execute "apt-get update"
  execute "apt-get install elixir"

when 'redhat', 'centos', 'fedora'
  elixir_tar_path    = Chef::Config[:file_cache_path] + '/' + node[:elixir][:source_tar]
  elixir_url         = node[:elixir][:source_url]
  elixir_src_path    = Chef::Config[:file_cache_path] + '/' + node[:elixir][:source_dir]
  elixir_root        = node[:elixir][:root]

  execute "Downloading #{node[:elixir][:source_tar]}" do
    command "wget --directory-prefix=#{Chef::Config[:file_cache_path]} #{elixir_url}"
    action  :run
    not_if { ::File.exists?(elixir_tar_path) }
  end

  execute "Extracting Archive #{node[:elixir][:source_tar]}" do
    cwd     Chef::Config[:file_cache_path]
    command "tar -zxf #{elixir_tar_path} --directory=#{Chef::Config[:file_cache_path]}"
    action  :run
    not_if { ::File.exists?(elixir_src_path) }
  end

  execute "Move Built Elixir to Install Location" do
    command "cp -r #{elixir_src_path} #{elixir_root}"
    action  :run
    not_if { ::File.exists?(node[:elixir][:bin]) }
  end

  execute "Make Elixir Source" do
    cwd     elixir_root
    command "export PATH=$PATH:#{node[:erlang][:bin]} && make"
    action  :run
    not_if { ::File.exists?("#{node[:elixir][:bin]}/iex") }
  end

  execute "Move Built Elixir executables to /usr/local/bin" do
    command "cp -r #{node[:elixir][:bin]}/* /usr/local/bin/"
    action  :run
    not_if { ::File.exists?("/usr/local/bin/iex") }
  end
end
