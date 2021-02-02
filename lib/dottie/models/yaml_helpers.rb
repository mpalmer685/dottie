# frozen_string_literal: true

require 'yaml'

module Dottie
  module Models
    module Yaml
      module ClassMethods
        def from_yaml(yaml)
          new(*YAML.load(yaml).values_at(*members))
        end
      end

      def to_yaml
        to_h.to_yaml
      end

      def self.included(includer)
        includer.extend ClassMethods
      end
    end
  end
end
