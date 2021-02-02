# frozen_string_literal: true

require 'dottie/models/yaml_helpers'

module Dottie
  module Models
    Config = Struct.new(:dotfile_path) do
      include Yaml
    end
  end
end
