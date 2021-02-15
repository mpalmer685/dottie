# frozen_string_literal: true

require 'dottie/models/yaml_helpers'

module Dottie
  module Models
    Profile = Struct.new(:repo_id, :location, :parent_id, keyword_init: true) do
      include KeywordYaml

      def id
        location.gsub(/\W/, '_')
      end
    end
  end
end
