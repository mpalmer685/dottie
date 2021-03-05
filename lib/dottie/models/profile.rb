# frozen_string_literal: true

require 'date'

require_relative 'shell_settings'
require_relative 'yaml_helpers'

module Dottie
  module Models
    Profile = Struct.new(:repo_id, :location, :shells, :installed_at, :processed_at, keyword_init: true) do
      include KeywordYaml

      def id
        location.gsub(/\W/, '_')
      end

      def name
        File.basename(location)
      end

      def mark_installed
        self.installed_at = DateTime.now
      end

      def mark_processed
        self.processed_at = DateTime.now
      end

      def add_shell(shell_type, shell_settings)
        self.shells ||= {}
        shell = shells[shell_type] || ShellSettings.new
        shells[shell_type] = shell.merge(shell_settings)
      end

      def shell_settings(shell_type)
        self.shells ||= {}
        shells.fetch(shell_type) { |_| ShellSettings.new }
      end
    end
  end
end
