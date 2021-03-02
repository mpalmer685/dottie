# frozen_string_literal: true

require 'dottie/file_system'
require 'dottie/logger'
require 'dottie/storage'

module Dottie
  module Commands
    class Link
      def initialize(
        model_storage = Dottie::Storage.new,
        file_system = Dottie::FileSystem.new,
        logger = Dottie::Logger.default
      )
        @model_storage = model_storage
        @file_system = file_system
        @logger = logger

        @config = @model_storage.config
      end

      def run(shell_type, link_path, force: false)
        shell_path = File.join(@config.dotfile_path, 'shells', "#{shell_type}.sh")
        raise not_generated_error(shell_type) unless @file_system.file?(shell_path)
        if @file_system.symlink?(link_path) && @file_system.symlink_path(link_path) != shell_path && !force
          raise symlink_exists(link_path)
        end
        raise file_exists(link_path) if @file_system.file?(link_path) && !@file_system.symlink?(link_path)

        @file_system.symlink(shell_path, link_path)
      end

      private

      def not_generated_error(shell_type)
        %(A shell startup file has not been generated for the #{shell_type} shell. Run "dottie generate #{shell_type}" first.)
      end

      def file_exists(link_path)
        "A file already exists at #{link_path}. Please delete it and try it again."
      end

      def symlink_exists(link_path)
        "#{link_path} is already a symlink. Remove it or rerun this command with the --force flag."
      end
    end
  end
end
