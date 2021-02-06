# frozen_string_literal: true

require 'dottie/models/repo'

module Dottie
  module Storage
    class Repos
      def initialize(
        dottie_config,
        profiles_settings,
        file_system = Dottie::FileSystem,
        git = Dottie::Git.new,
        logger = Dottie::Logger.default
      )
        @dottie_config = dottie_config
        @profiles_settings = profiles_settings
        @file_system = file_system
        @git = git
        @logger = logger
      end

      def install(**repo_options)
        repo = repo_from_options(**repo_options)
        return repo unless @profiles_settings.repo(repo.id).nil?

        clone_location = File.join(@dottie_config.dotfile_path, 'repos', repo.id)
        @git.clone(repo, clone_location)
        @profiles_settings.add_repo(repo)
      end

      private

      def repo_from_options(url: nil, git: nil, github: nil, **definition)
        if !url.nil?
          Dottie::Models::Repo.from_definition(url: url, **definition)
        elsif !git.nil?
          Dottie::Models::Repo.from_git(git, **definition)
        elsif !github.nil?
          Dottie::Models::Repo.from_github(github, **definition)
        end
      end
    end
  end
end
