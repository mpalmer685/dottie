# frozen_string_literal: true

require 'date'

require 'dottie/models/yaml_helpers'

module Dottie
  module Models
    Profile = Struct.new(:repo_id, :location, :parent_id, :installed_at, :processed_at, keyword_init: true) do
      include KeywordYaml

      def id
        location.gsub(/\W/, '_')
      end

      def name
        File.basename(location)
      end

      def mark_installed
        self.installed_at = DateTime.now
      end

      def mark_processed
        self.processed_at = DateTime.now
      end
    end
  end
end
