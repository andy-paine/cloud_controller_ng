# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: image_layer.proto

require 'google/protobuf'

Google::Protobuf::DescriptorPool.generated_pool.build do
  add_file("image_layer.proto", :syntax => :proto3) do
    add_message "diego.bbs.models.ImageLayer" do
      optional :name, :string, 1
      optional :url, :string, 2
      optional :destination_path, :string, 3
      optional :layer_type, :enum, 4, "diego.bbs.models.ImageLayer.Type"
      optional :media_type, :enum, 5, "diego.bbs.models.ImageLayer.MediaType"
      optional :digest_algorithm, :enum, 6, "diego.bbs.models.ImageLayer.DigestAlgorithm"
      optional :digest_value, :string, 7
    end
    add_enum "diego.bbs.models.ImageLayer.DigestAlgorithm" do
      value :DigestAlgorithmInvalid, 0
      value :SHA256, 1
      value :SHA512, 2
    end
    add_enum "diego.bbs.models.ImageLayer.MediaType" do
      value :MediaTypeInvalid, 0
      value :TGZ, 1
      value :TAR, 2
      value :ZIP, 3
    end
    add_enum "diego.bbs.models.ImageLayer.Type" do
      value :LayerTypeInvalid, 0
      value :SHARED, 1
      value :EXCLUSIVE, 2
    end
  end
end

module Diego
  module Bbs
    module Models
      ImageLayer = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("diego.bbs.models.ImageLayer").msgclass
      ImageLayer::DigestAlgorithm = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("diego.bbs.models.ImageLayer.DigestAlgorithm").enummodule
      ImageLayer::MediaType = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("diego.bbs.models.ImageLayer.MediaType").enummodule
      ImageLayer::Type = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("diego.bbs.models.ImageLayer.Type").enummodule
    end
  end
end
