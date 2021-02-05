# frozen_string_literal: true

require 'dottie/models/yaml_helpers'

module Dottie
  module Models
    ProfilesSettings = Struct.new(:repos, :profiles, :shells, keyword_init: true) do
      include KeywordYaml

      def add_repo(repo)
        self.repos ||= {}
        self.repos[repo.id] = repo
        repo
      end

      def repo(id)
        return if self.repos.nil?

        self.repos[id]
      end

      def add_profile(profile)
        self.profiles ||= {}
        self.profiles[profile.id] = profile
        profile
      end

      def profile(id)
        return if self.profiles.nil?

        self.profiles[id]
      end
    end
  end
end
