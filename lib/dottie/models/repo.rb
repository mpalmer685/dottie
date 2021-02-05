# frozen_string_literal: true

require 'dottie/models/yaml_helpers'

module Dottie
  module Models
    Repo = Struct.new(:url, :branch, :tag, :commit, :id) do
      include Yaml

      def self.from_definition(definition)
        url, branch, tag, commit = definition.values_at('url', 'branch', 'tag', 'commit')
        id = build_id(url, branch, tag, commit)
        new(url, branch, tag, commit, id)
      end

      def self.build_id(url, branch, tag, commit)
        [url, branch, tag, commit].join('_').gsub(/\W/, '_')
      end
      private_class_method :build_id
    end
  end
end
