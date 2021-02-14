# frozen_string_literal: true

require 'dottie/models/config'
require 'dottie/models/exec_cache'
require 'dottie/models/profile'
require 'dottie/models/repo'
require 'dottie/models/yaml_helpers'

module Dottie
  module Models
    Config = Struct.new(:dotfile_path, :repos, :profiles, :shells, keyword_init: true) do
      include KeywordYaml

      def self.config_file_location(os)
        File.join(os.config_dir, 'config.yml')
      end

      def add_repo(repo)
        self.repos ||= {}
        self.repos[repo.id] = repo
        repo
      end

      def repo(id)
        self.repos.nil? ? nil : self.repos[id]
      end

      def add_profile(profile)
        self.profiles ||= {}
        self.profiles[profile.id] = profile
        profile
      end

      def profile(id)
        self.profiles.nil? ? nil : self.profiles[id]
      end

      def add_shell(shell_type, shell_settings)
        self.shells ||= {}
        shell = self.shells[shell_type] || {}
        shell.merge!(shell_settings)
      end
    end
  end
end
