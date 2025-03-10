require 'presenters/v3/app_manifest_presenter'
require 'messages/app_manifest_message'
require 'json-diff'

module VCAP::CloudController
  class SpaceDiffManifest
    # rubocop:todo Metrics/CyclomaticComplexity
    def self.filter_manifest_app_hash(manifest_app_hash)
      if manifest_app_hash.key? 'sidecars'
        manifest_app_hash['sidecars'] = manifest_app_hash['sidecars'].map do |hash|
          hash.slice(
            'name',
            'command',
            'process_types',
            'memory'
          )
        end
        manifest_app_hash['sidecars'] = convert_byte_measurements_to_mb(manifest_app_hash['sidecars'])
        manifest_app_hash = manifest_app_hash.except('sidecars') if manifest_app_hash['sidecars'] == [{}]
      end
      if manifest_app_hash.key? 'processes'
        manifest_app_hash['processes'] = manifest_app_hash['processes'].map do |hash|
          hash.slice(
            'type',
            'command',
            'disk_quota',
            'health-check-http-endpoint',
            'health-check-invocation-timeout',
            'health-check-type',
            'instances',
            'memory',
            'timeout'
          )
        end
        manifest_app_hash['processes'] = convert_byte_measurements_to_mb(manifest_app_hash['processes'])
        manifest_app_hash = manifest_app_hash.except('processes') if manifest_app_hash['processes'] == [{}]
      end

      if manifest_app_hash.key? 'services'
        manifest_app_hash['services'] = manifest_app_hash['services'].map do |hash|
          if hash.is_a? String
            hash
          else
            hash.slice(
              'name',
              'parameters'
            )
          end
        end
        manifest_app_hash = manifest_app_hash.except('services') if manifest_app_hash['services'] == [{}]
      end

      if manifest_app_hash.key? 'metadata'
        manifest_app_hash['metadata'] = manifest_app_hash['metadata'].slice(
          'labels',
          'annotations'
        )
        manifest_app_hash = manifest_app_hash.except('metadata') if manifest_app_hash['metadata'] == {}
      end

      manifest_app_hash
    end
    # rubocop:enable Metrics/CyclomaticComplexity

    # rubocop:todo Metrics/CyclomaticComplexity
    def self.generate_diff(app_manifests, space)
      json_diff = []
      recognized_top_level_keys = AppManifestMessage.allowed_keys.map(&:to_s)
      app_manifests = convert_byte_measurements_to_mb(app_manifests)
      app_manifests.each_with_index do |manifest_app_hash, index|
        manifest_app_hash = SpaceDiffManifest.filter_manifest_app_hash(manifest_app_hash)
        existing_app = space.app_models.find { |app| app.name == manifest_app_hash['name'] }

        if existing_app.nil?
          existing_app_hash = {}
        else
          manifest_presenter = Presenters::V3::AppManifestPresenter.new(
            existing_app,
            existing_app.service_bindings,
            existing_app.routes,
          )
          existing_app_hash = manifest_presenter.to_hash.deep_stringify_keys['applications'][0]
          web_process_hash = existing_app_hash['processes'].find { |p| p['type'] == 'web' }
          existing_app_hash = existing_app_hash.merge(web_process_hash) if web_process_hash

          # Account for the fact that older manifests may have a hyphen for disk-quota
          if manifest_app_hash.key?('disk-quota')
            existing_app_hash['disk-quota'] = existing_app_hash['disk_quota']
            recognized_top_level_keys << 'disk-quota'
          end
        end

        manifest_app_hash.each do |key, value|
          next unless recognized_top_level_keys.include?(key)

          existing_value = existing_app_hash[key]
          if key == 'processes' && existing_value.present?
            remove_default_missing_fields(existing_value, 'processes', 'type', key, value)
          end
          if key == 'sidecars' && existing_value.present?
            remove_default_missing_fields(existing_value, 'sidecars', 'name', key, value)
          end

          key_diffs = JsonDiff.diff(
            existing_value,
            value,
            include_was: true,
            similarity: create_similarity
          )

          key_diffs.each do |diff|
            diff['path'] = "/applications/#{index}/#{key}" + diff['path']

            if diff['op'] == 'replace' && diff['was'].nil?
              diff['op'] = 'add'
            end

            json_diff << diff
          end
        end
      end
      # rubocop:enable Metrics/CyclomaticComplexity

      json_diff
    end

    def self.create_similarity
      ->(before, after) do
        return nil unless before.is_a?(Hash) && after.is_a?(Hash)

        if before.key?('type') && after.key?('type')
          return before['type'] == after['type'] ? 1.0 : 0.0
        elsif before.key?('name') && after.key?('name')
          return before['name'] == after['name'] ? 1.0 : 0.0
        end

        nil
      end
    end

    def self.convert_byte_measurements_to_mb(manifest_app_hash)
      byte_measurement_key_words = ['memory', 'disk-quota', 'disk_quota']
      manifest_app_hash.each_with_index do |process_hash, index|
        byte_measurement_key_words.each do |key|
          value = process_hash[key]
          manifest_app_hash[index][key] = convert_to_mb(value, key) unless value.nil?
        end
      end
      manifest_app_hash
    end

    def self.convert_to_mb(human_readable_byte_value, attribute_name)
      byte_converter.convert_to_mb(human_readable_byte_value).to_s + 'M'
    rescue ByteConverter::InvalidUnitsError
      "#{attribute_name} must use a supported unit: B, K, KB, M, MB, G, GB, T, or TB"
    rescue ByteConverter::NonNumericError
      "#{attribute_name} is not a number"
    end

    def self.byte_converter
      ByteConverter.new
    end

    def self.remove_default_missing_fields(existing_value, resource_type, identifying_field, current_key, value)
      existing_value.each_with_index do |resource, i|
        manifest_app_hash_resource = value.find { |hash_resource| hash_resource[identifying_field] == resource[identifying_field] }
        if manifest_app_hash_resource.nil?
          existing_value.delete_at(i)
        else
          resource.each do |k, v|
            if manifest_app_hash_resource[k].nil?
              existing_value[i].delete(k)
            end
          end
        end
      end
    end
  end
end
