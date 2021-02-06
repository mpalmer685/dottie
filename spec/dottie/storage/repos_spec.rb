# frozen_string_literal: true

require 'dottie/models/config'
require 'dottie/models/profiles_settings'
require 'dottie/models/repo'
require 'dottie/storage/repos'
require 'dottie/git'
require 'dottie/logger'

files = {
  home: {
    dottie: {
      profiles: {},
      repos: {},
      shells: {}
    }
  }
}

describe Dottie::Storage::Repos do
  subject { described_class.new(dottie_config, profiles_settings, file_system, git, logger) }
  let(:dottie_config) { Dottie::Models::Config.new('/home/dottie') }
  let(:profiles_settings) { Dottie::Models::ProfilesSettings.new }
  let(:file_system) { SpecHelper::FileSystem.new.use(files) }
  let(:git) { object_double(Dottie::Git.new) }
  let(:logger) { Dottie::Logger.silent }

  it 'should clone a repo that is not installed' do
    expect(git).to receive(:clone).with(anything, '/home/dottie/repos/git_repo')

    subject.install(git: 'git-repo')
    expect(profiles_settings.repo('git_repo')).not_to be_nil
  end

  it 'should not clone a repo that is already installed' do
    profiles_settings.add_repo(Dottie::Models::Repo.from_git('git-repo'))
    expect(git).not_to receive(:clone).with(anything, '/home/dottie/repos/git_repo')

    subject.install(git: 'git-repo')
    expect(profiles_settings.repo('git_repo')).not_to be_nil
  end
end
