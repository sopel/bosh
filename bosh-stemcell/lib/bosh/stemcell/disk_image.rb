require 'bosh/core/shell'

module Bosh::Stemcell
  class DiskImage
    def initialize(options)
      @image_file_path = options.fetch(:image_file_path)
      @mount_point = options.fetch(:mount_point)
      @shell = Bosh::Core::Shell.new
    end

    def mount
      shell.run("mount #{stemcell_loopback_device_name} #{mount_point}")
    end

    def unmount
      shell.run("umount #{mount_point}")
      unmap_image
    end

    private

    attr_reader :image_file_path, :mount_point, :shell

    def stemcell_loopback_device_name
      "/dev/mapper/#{map_image}"
    end

    def map_image
      unless @image_device
        output = shell.run("kpartx -av #{image_file_path}")
        @image_device = output.split(' ')[2]
      end
      @image_device
    end

    def unmap_image
      shell.run("kpartx -dv #{image_file_path}")
    end
  end
end