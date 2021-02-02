# frozen_string_literal: true

require 'dottie/models/config'

module Dottie
  class Resetter
    def initialize(file_system, os)
      @file_system = file_system
      @os = os

      config_yaml = @file_system.read_file(File.join(@os.config_dir, 'dottie_config.yml'))
      @dotfile_path = Dottie::Models::Config.from_yaml(config_yaml).dotfile_path
    end

    def reset
      @file_system.delete_directory @dotfile_path
      @file_system.delete_directory @os.config_dir
    end
  end
end
