# frozen_string_literal: true

require 'dottie/template'

module Dottie
  module Generator
    class ShellContext < Dottie::Template::Context
      def initialize(shell_settings)
        @settings = shell_settings.commands.group_by(&:type)
        @settings[:env] = Array(shell_settings.environment_vars)
      end

      def env
        @settings[:env]
      end

      def path_add
        settings_paths(:path_add)
      end

      def fpath_add
        settings_paths(:fpath_add)
      end

      def source
        settings_paths(:source)
      end

      private

      def settings_paths(setting)
        return [] unless @settings.key?(setting)

        @settings[setting].map { |entry| entry.options[:path] }
      end
    end
  end
end
