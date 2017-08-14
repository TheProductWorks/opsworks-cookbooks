node[:efs][:devices].each do |device, options|
  directory options[:mount_point] do
    recursive true
    action :create
    mode "0755"
  end

  if options[:mount_point].nil? || options[:mount_point].empty?
    log "skip mounting volume #{device} because no mount_point specified"
    next
  end

  # sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 fs-fbf22e32.efs.eu-west-1.amazonaws.com:/ efs
  mount options[:mount_point] do
    action [:mount, :enable]
    fstype 'nfs4'
    device device
    options 'nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2'
    pass 0
  end
end
