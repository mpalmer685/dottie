# frozen_string_literal: true

module Dottie
  class Dotfile
    module PostInstallHooks
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

      def self.define_logging_level(name)
        define_method(name) do |*msg|
          @logger.send(name, *msg)
        end
      end

      define_logging_level :info
      define_logging_level :success
      define_logging_level :warn
      define_logging_level :error
    end
  end
end
