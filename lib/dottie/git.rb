# frozen_string_literal: true

module Dottie
  class Git
    def initialize(shell = Dottie::Shell.new)
      @shell = shell
    end

    def clone(repo, location)
      args = ['--depth 1']
      args << "-b #{repo.branch}" unless repo.branch.nil?
      args << "-b #{repo.tag}" unless repo.tag.nil?
      @shell.run('git clone', *args, repo.url, location)
    end
  end
end
