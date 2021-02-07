# frozen_string_literal: true

require 'dottie/models/yaml_helpers'

module Dottie
  module Models
    Profile = Struct.new(:repo_id, :location, :parent_id, :id, keyword_init: true) do
      include KeywordYaml
    end
  end
end
