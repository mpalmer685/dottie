# frozen_string_literal: true

require 'dottie/models/yaml_helpers'

module Dottie
  module Models
    Config = Struct.new(:dotfile_path) do
      include Yaml

      def self.config_file_location(os)
        File.join(os.config_dir, 'dottie_config.yml')
      end
    end
  end
end
