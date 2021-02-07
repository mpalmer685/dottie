# frozen_string_literal: true

require 'dottie/models/config'
require 'dottie/models/profiles_settings'
require 'dottie/models/exec_cache'
require 'dottie/file_system'
require 'dottie/logger'
require 'dottie/os'

module Dottie
  module Commands
    class Init
      def initialize(file_system = Dottie::FileSystem, os = Dottie::OS.current, logger = Dottie::Logger.default)
        @file_system = file_system
        @os = os
        @logger = logger
      end

      def run(dotfile_path)
        raise "#{dotfile_path} already exists and is not empty" unless directory_available? dotfile_path
        raise "#{@os.config_dir} is not empty" unless directory_available? @os.config_dir

        @logger.info "Setting up dottie at #{dotfile_path}"
        create_folder_structure dotfile_path
        create_config_dir
        write_config_files dotfile_path
      end

      private

      def directory_available?(path)
        !@file_system.exist?(path) || (@file_system.directory?(path) && @file_system.empty?(path))
      end

      def create_folder_structure(dotfile_path)
        %w[repos shells].each do |folder|
          @file_system.mkdir File.join(dotfile_path, folder)
        end
      end

      def create_config_dir
        @file_system.mkdir @os.config_dir
      end

      def write_config_files(dotfile_path)
        Dottie::Models::Config.new(dotfile_path).save(@file_system, @os)
        Dottie::Models::ProfilesSettings.new.save(@file_system, @os)
        Dottie::Models::ExecCache.new.save(@file_system, @os)
      end
    end
  end
end
