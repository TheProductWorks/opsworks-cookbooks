###
# Do not use this file to override the gunicorn cookbook's default
# attributes.  Instead, please use the customize.rb attributes file,
# which will keep your adjustments separate from the AWS OpsWorks
# codebase and make it easier to upgrade.
#
# However, you should not edit customize.rb directly. Instead, create
# "gunicorn/attributes/customize.rb" in your cookbook repository and
# put the overrides in YOUR customize.rb file.
#
# Do NOT create an 'gunicorn/attributes/default.rb' in your cookbooks. Doing so
# would completely override this file and might cause upgrade issues.
#
# See also: http://docs.aws.amazon.com/opsworks/latest/userguide/customizing.html
###

default[:gunicorn][:worker_processes] = 4
default[:gunicorn][:backlog] = 1024
default[:gunicorn][:timeout] = 60
default[:gunicorn][:preload_app] = true
default[:gunicorn][:version] = '4.7.0'
default[:gunicorn][:tcp_nodelay] = true
default[:gunicorn][:tcp_nopush] = false
default[:gunicorn][:tries] = 5
default[:gunicorn][:delay] = 0.5
default[:gunicorn][:accept_filter] = "httpready"
default[:gunicorn][:rack_version] = "1.6.4"

include_attribute "gunicorn::customize"
