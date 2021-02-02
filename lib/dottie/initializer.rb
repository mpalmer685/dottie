# frozen_string_literal: true

require 'dottie/models/config'
require 'dottie/models/profiles_settings'
require 'dottie/models/exec_cache'

module Dottie
  class Initializer
    def initialize(file_system, os)
      @file_system = file_system
      @os = os
    end

    def init(dotfile_path)
      raise "#{dotfile_path} already exists and is not empty" unless directory_available? dotfile_path
      raise "#{@os.config_dir} is not empty" unless directory_available? @os.config_dir

      create_folder_structure dotfile_path
      create_config_dir
      write_config_files dotfile_path
    end

    private

    def directory_available?(path)
      !@file_system.exist?(path) || (@file_system.directory?(path) && @file_system.empty?(path))
    end

    def create_folder_structure(dotfile_path)
      %w[repos profiles shells].each do |folder|
        @file_system.mkdir File.join(dotfile_path, folder)
      end
    end

    def create_config_dir
      @file_system.mkdir @os.config_dir
    end

    def write_config_files(dotfile_path)
      write_config 'dottie_config.yml', Dottie::Models::Config.new(dotfile_path)
      write_config 'profiles_settings.yml', Dottie::Models::ProfilesSettings.new
      write_config 'exec_cache.yml', Dottie::Models::ExecCache.new
    end

    def write_config(file_name, config)
      file_path = File.join @os.config_dir, file_name
      @file_system.write_file file_path, config.to_yaml
    end
  end
end
