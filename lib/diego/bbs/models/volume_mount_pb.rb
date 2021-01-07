# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: volume_mount.proto

require 'google/protobuf'

Google::Protobuf::DescriptorPool.generated_pool.build do
  add_file("volume_mount.proto", :syntax => :proto3) do
    add_message "diego.bbs.models.SharedDevice" do
      optional :volume_id, :string, 1
      optional :mount_config, :string, 2
    end
    add_message "diego.bbs.models.VolumeMount" do
      optional :driver, :string, 1
      optional :container_dir, :string, 3
      optional :mode, :string, 6
      optional :shared, :message, 7, "diego.bbs.models.SharedDevice"
    end
    add_message "diego.bbs.models.VolumePlacement" do
      repeated :driver_names, :string, 1
    end
  end
end

module Diego
  module Bbs
    module Models
      SharedDevice = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("diego.bbs.models.SharedDevice").msgclass
      VolumeMount = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("diego.bbs.models.VolumeMount").msgclass
      VolumePlacement = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("diego.bbs.models.VolumePlacement").msgclass
    end
  end
end
