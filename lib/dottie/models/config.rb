# frozen_string_literal: true

require 'dottie/models/config'
require 'dottie/models/exec_cache'
require 'dottie/models/profile'
require 'dottie/models/repo'
require 'dottie/models/shell_settings'
require 'dottie/models/yaml_helpers'

module Dottie
  module Models
    class Config
      include KeywordYaml

      attr_accessor :dotfile_path

      def initialize(config = {})
        @dotfile_path = config.fetch(:dotfile_path, '')
        @repos = config.fetch(:repos, {})
        @profiles = config.fetch(:profiles, {})
        @installed_profiles = config.fetch(:installed_profiles, [])
      end

      def add_repo(repo)
        @repos[repo.id] = repo
      end

      def repo(id)
        @repos[id]
      end

      def add_profile(profile)
        @installed_profiles << profile.id
        @profiles[profile.id] = profile
      end

      def profile(id)
        @profiles[id]
      end

      def profile_description(profile)
        profile.repo_id.nil? ? profile.location : repo(profile.repo_id).url
      end

      def profiles
        @installed_profiles.map { |id| profile(id) }
      end

      def shell_settings(shell_type)
        profiles.reduce(ShellSettings.new) { |settings, p| settings.merge(p.shell_settings(shell_type)) }
      end

      def self.config_file_location(os)
        File.join(os.config_dir, 'config.yml')
      end

      def to_h
        {
          dotfile_path: @dotfile_path,
          repos: @repos,
          profiles: @profiles,
          installed_profiles: @installed_profiles
        }
      end
    end
  end
end
