# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: sidecar.proto

require 'google/protobuf'

require 'actions_pb'
Google::Protobuf::DescriptorPool.generated_pool.build do
  add_file("sidecar.proto", :syntax => :proto3) do
    add_message "diego.bbs.models.Sidecar" do
      optional :action, :message, 1, "diego.bbs.models.Action"
      optional :disk_mb, :int32, 2
      optional :memory_mb, :int32, 3
    end
  end
end

module Diego
  module Bbs
    module Models
      Sidecar = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("diego.bbs.models.Sidecar").msgclass
    end
  end
end
