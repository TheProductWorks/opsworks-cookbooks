# Cookbook Name:: erlang
# Recipe:: default
# Author:: Joe Williams <joe@joetify.com>
# Author:: Matt Ray <matt@opscode.com>
#
# Copyright 2008-2009, Joe Williams
# Copyright 2011, Opscode Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

case node[:platform]
when "debian", "ubuntu"
  if node[:erlang][:manual_compile]
    remote_file "/usr/local/src/otp_src_#{node[:erlang][:version]}.tar.gz" do
      source "http://www.erlang.org/download/otp_src_#{node[:erlang][:version]}.tar.gz"
      action :create_if_missing
      notifies :run, 'bash[install_erlang]', :immediate
    end

    bash "install_erlang" do
      user "root"
      cwd "/usr/local/src"
      code <<-EOH
        tar -zxf otp_src_#{node[:erlang][:version]}.tar.gz
        cd otp_src_#{node[:erlang][:version]}/
        sed -i 's/defined(FUTEX_WAIT_PRIVATE) && defined(FUTEX_WAKE_PRIVATE)/false/' erts/include/internal/pthread/ethr_event.h
        (./configure #{node[:erlang][:build_flags]} && make install && ln -s /usr/local/bin/erl /bin/erl)
      EOH
      action :nothing
    end
  else
    erlpkg = node[:erlang][:gui_tools] ? "erlang" : "erlang-nox"
    package erlpkg
    package "erlang-dev"
  end
when "redhat", "centos", "scientific"
  if node[:erlang][:manual_compile]
    remote_file "/usr/local/src/otp_src_#{node[:erlang][:version]}.tar.gz" do
      source "http://www.erlang.org/download/otp_src_#{node[:erlang][:version]}.tar.gz"
      action :create_if_missing
      notifies :run, 'bash[install_erlang]', :immediate
    end

    bash "install_erlang" do
      user "root"
      cwd "/usr/local/src"
      code <<-EOH
        tar -zxf otp_src_#{node[:erlang][:version]}.tar.gz
        cd otp_src_#{node[:erlang][:version]}/
        sed -i 's/defined(FUTEX_WAIT_PRIVATE) && defined(FUTEX_WAKE_PRIVATE)/false/' erts/include/internal/pthread/ethr_event.h
        (./configure #{node[:erlang][:build_flags]} && make install && ln -s /usr/local/bin/erl /bin/erl)
      EOH
      action :nothing
    end
  else
    include_recipe "yum::epel"
    yum_repository "erlang" do
      name "EPELErlangrepo"
      url "http://repos.fedorapeople.org/repos/peter/erlang/epel-5Server/$basearch"
      description "Updated erlang yum repository for RedHat / Centos 5.x - #{node['kernel']['machine']}"
      action :add
      only_if { node[:platform_version].to_f >= 5.0 && node[:platform_version].to_f < 6.0 }
      package "erlang"
    end
  end
else
  package "erlang"
end
