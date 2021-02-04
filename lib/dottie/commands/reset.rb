# frozen_string_literal: true

require 'pastel'
require 'tty-prompt'

require 'dottie/models/config'
require 'dottie/file_system'
require 'dottie/logger'
require 'dottie/os'

module Dottie
  module Commands
    class Reset
      def initialize(
        file_system = Dottie::FileSystem,
        os = Dottie::OS.current,
        logger = Dottie::Logger.default,
        prompt = TTY::Prompt.new
      )
        @file_system = file_system
        @os = os
        @logger = logger
        @prompt = prompt
        @dotfile_path = dottie_config.dotfile_path
      end

      def run
        warning = Pastel.new.yellow.bold('Warning')
        return if @prompt.no?("#{warning} This will remove all Dottie files and settings. Continue?")

        @logger.info('Removing dottie files and settings')
        @file_system.delete_directory(@dotfile_path)
        @file_system.delete_directory(@os.config_dir)
      end

      private

      def dottie_config
        config_location = File.join(@os.config_dir, 'dottie_config.yml')
        config_yaml = @file_system.read_file(config_location)
        Dottie::Models::Config.from_yaml(config_yaml)
      end
    end
  end
end
