# frozen_string_literal: true

require 'dottie/models/yaml_helpers'

module Dottie
  module Models
    ExecCache = Struct.new(:profiles) do
      include Yaml

      def self.config_file_location(os)
        File.join(os.config_dir, 'exec_cache.yml')
      end
    end
  end
end

