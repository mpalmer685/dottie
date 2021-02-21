# frozen_string_literal: true

module Dottie
  class Dotfile
    module PostInstallHooks

      # File System

      def symlink?(symlink)
        @file_system.symlink?(symlink)
      end

      def symlink_path(symlink)
        @file_system.symlink_path(symlink)
      end

      def symlink(from, to)
        @file_system.symlink(from, to)
      end

      def mkdir(path)
        @file_system.mkdir(path)
      end

      # Logging

      def self.define_logging_level(name)
        define_method(name) do |*msg|
          @logger.send(name, *msg)
        end
      end

      define_logging_level :info
      define_logging_level :success
      define_logging_level :warn
      define_logging_level :error

      # Shell

      def exec(cmd, once: false)
        @shell.run(cmd, cwd: @profile.location)
      end

      def sudo(cmd, once: false)
        @shell.sudo(cmd, cwd: @profile.location)
      end

      def exec_file(path, once: false)
        @shell.exec_file(File.join(@profile.location, path))
      end

      def command_exists?(command)
        @shell.command_exists?(command)
      end
    end
  end
end
