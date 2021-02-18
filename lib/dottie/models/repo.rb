# frozen_string_literal: true

require 'dottie/models/yaml_helpers'

module Dottie
  module Models
    Repo = Struct.new(:url, :branch, :tag, :id, keyword_init: true) do
      include KeywordYaml

      def self.from_git(git_url, **definition)
        from_definition(url: git_url, **definition)
      end

      def self.from_github(github_repo, ssh: false, **definition)
        url = if ssh
                "git@github.com:#{github_repo}.git"
              else
                "https://github.com/#{github_repo}.git"
              end
        from_definition(url: url, **definition)
      end

      def self.from_definition(definition)
        url, branch, tag = definition.values_at(:url, :branch, :tag)
        id = build_id(url, branch, tag)
        new(id: id, **definition)
      end

      def self.build_id(url, branch, tag)
        segments = [url]
        segments << "b#{branch}" if branch
        segments << "t#{tag}" if tag
        segments.join('_').gsub(/\W/, '_')
      end
      private_class_method :build_id
    end
  end
end
