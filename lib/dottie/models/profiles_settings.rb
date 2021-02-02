# frozen_string_literal: true

require 'dottie/models/yaml_helpers'

module Dottie
  module Models
    ProfilesSettings = Struct.new(:repos, :profiles, :shells) do
      include Yaml
    end
  end
end
