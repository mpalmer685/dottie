# frozen_string_literal: true

require 'dottie/models/config'
require 'dottie/dotfile'
require 'dottie/file_system'
require 'dottie/git'
require 'dottie/os'
require 'dottie/logger'

module Dottie
  module Commands
    class Install
      def initialize(
        model_storage,
        file_system = Dottie::FileSystem,
        git = Dottie::Git.new,
        shell = Dottie::Shell,
        logger = Dottie::Logger.default
      )
        @model_storage = model_storage
        @file_system = file_system
        @git = git
        @shell = shell
        @logger = logger

        @config = @model_storage.config
      end

      def run(path, repo_definition = nil)
        profile, repo = get_installation(path, repo_definition)

        unless @config.profile(profile.id).nil?
          @logger.info('Profile is already installed')
          return
        end

        install_profile(profile, repo)
        process_dotfile(profile)

        @model_storage.save_model(@config)
      end

      private

      def get_installation(path, repo_definition)
        if repo_definition.nil? || repo_definition.empty?
          profile = local_profile(path)
          repo = nil
        else
          repo = repo_from_options(repo_definition)
          profile = remote_profile(repo.id, path)
        end
        [profile, repo]
      end

      def local_profile(path)
        source_location = File.expand_path(path)
        Dottie::Models::Profile.new(location: source_location)
      end

      def remote_profile(repo_id, path)
        source_location = File.join(@config.dotfile_path, 'repos', repo_id, path)
        Dottie::Models::Profile.new(repo_id: repo_id, location: source_location)
      end

      def repo_from_options(url: nil, git: nil, github: nil, **definition)
        if !url.nil?
          Dottie::Models::Repo.from_definition(url: url, **definition)
        elsif !git.nil?
          Dottie::Models::Repo.from_git(git, **definition)
        elsif !github.nil?
          Dottie::Models::Repo.from_github(github, **definition)
        end
      end

      def install_profile(profile, repo)
        install_repo(repo) unless repo.nil?

        @config.add_profile(profile) if @config.profile(profile.id).nil?
      end

      def install_repo(repo)
        return unless @config.repo(repo.id).nil?

        clone_location = File.join(@config.dotfile_path, 'repos', repo.id)
        @git.clone(repo, clone_location)
        @config.add_repo(repo)
      end

      def process_dotfile(profile)
        dotfile = Dotfile.from_profile(profile.location, @file_system)
        dotfile.shells.each_pair do |shell_type, settings|
          @config.add_shell(shell_type, settings)
        end
      end
    end
  end
end
