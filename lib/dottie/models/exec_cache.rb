# frozen_string_literal: true

require 'dottie/models/yaml_helpers'

module Dottie
  module Models
    ExecCache = Struct.new(:profiles) do
      include Yaml
    end
  end
end

