node[:efs][:devices].each do |device, options|
  mount options[:mount_point] do
    action :umount
    device device
  end
end
