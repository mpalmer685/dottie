# frozen_string_literal: true

require 'yaml'

module Dottie
  module Models
    module YamlCommon
      def to_yaml
        to_h.transform_keys(&:to_s).to_yaml
      end

      def save(file_system, os)
        file_path = self.class.config_file_location(os)
        file_system.write_file(file_path, to_yaml)
      end
    end

    module Yaml
      module ClassMethods
        def from_yaml(yaml)
          new(*YAML.load(yaml).transform_keys(&:to_sym).values_at(*members))
        end

        def load_yaml(file_system, os)
          from_yaml(file_system.read_file(config_file_location(os)))
        end
      end

      include YamlCommon

      def self.included(includer)
        includer.extend ClassMethods
      end
    end

    module KeywordYaml
      module ClassMethods
        def from_yaml(yaml)
          new(YAML.load(yaml).transform_keys(&:to_sym))
        end

        def load_yaml(file_system, os)
          from_yaml(file_system.read_file(config_file_location(os)))
        end
      end

      include YamlCommon

      def self.included(includer)
        includer.extend ClassMethods
      end
    end
  end
end
