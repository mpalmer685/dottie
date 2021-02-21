# frozen_string_literal: true

require 'dottie/models/yaml_helpers'

module Dottie
  module Models
    ExecCache = Struct.new(:profiles) do
      include Yaml

      def self.config_file_location(os)
        File.join(os.config_dir, 'exec_cache.yml')
      end

      def add_command(profile, cmd)
        self.profiles ||= {}
        self.profiles[profile.id] ||= Set.new
        self.profiles[profile.id] << cmd
      end

      def contain?(profile, cmd)
        !self.profiles.nil? && self.profiles.key?(profile.id) && self.profiles[profile.id].include?(cmd)
      end
    end
  end
end
