# frozen_string_literal: true

require 'dottie/models/profile'
require 'dottie/file_system'
require 'dottie/logger'

module Dottie
  module Storage
    class Profiles
      def initialize(dottie_config, profiles_settings, file_system = Dottie::FileSystem, logger = Dottie::Logger.default)
        @dottie_config = dottie_config
        @profiles_settings = profiles_settings
        @file_system = file_system
        @logger = logger
      end

      def install_from_local(path)
        source_location = File.expand_path(path)
        profile_id = source_location.gsub(/\W/, '_')
        profile_location = File.join(@dottie_config.dotfile_path, 'profiles', profile_id)
        profile = Dottie::Models::Profile.new(source_path: source_location, id: profile_id)

        return profile if @file_system.symlink?(profile_location)

        @file_system.symlink(profile_location, source_location)
        @profiles_settings.add_profile(profile)
      end

      def install_from_repo(repo_id, path)
        repo = @profiles_settings.repo(repo_id)
        source_location = File.join(@dottie_config.dotfile_path, 'repos', repo_id, path)
        profile_id = [repo.id, path].join('__').gsub(/\W/, '_')
        profile_location = File.join(@dottie_config.dotfile_path, 'profiles', profile_id)
        profile = Dottie::Models::Profile.new(repo_id: repo_id, source_path: path, id: profile_id)

        return profile if @file_system.symlink?(profile_location)

        @file_system.symlink(profile_location, source_location)
        @profiles_settings.add_profile(profile)
      end

      def uninstall(profile_id)
        profile_location = File.join(@dottie_config.dotfile_path, 'profiles', profile_id)
        @file_system.unlink(profile_location)
        @profiles_settings.remove_profile(profile_id)
      end
    end
  end
end
