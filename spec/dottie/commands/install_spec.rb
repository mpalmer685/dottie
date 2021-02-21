# frozen_string_literal: true

require 'dottie/commands/install'
require 'dottie/storage'

RSpec::Matchers.define :profile_at do |location|
  match { |actual| (actual.is_a? Dottie::Models::Profile) && (actual.location == location) }
end

files = {
  home: {
    dottie: {
      repos: {},
      shells: {}
    },
    profiles: {
      test: {}
    },
    config: {
      dottie: {}
    }
  }
}

describe Dottie::Commands::Install do
  subject { Dottie::Commands::Install.new(storage, file_system, git, shell, Dottie::Logger.silent) }

  # Dependencies
  let(:config) { Dottie::Models::Config.new(dotfile_path: '/home/dottie') }
  let(:exec_cache) { Dottie::Models::ExecCache.new }
  let(:file_system) { SpecHelper::FileSystem.new.use(files) }
  let(:os) { SpecHelper::OS.new.use(:macos, '/home/config') }
  let(:storage) do
    storage = Dottie::Storage.new(file_system, os)
    storage.config = config
    storage.exec_cache = exec_cache
    storage
  end
  let(:git) { instance_double(Dottie::Git) }
  let(:shell) { instance_double(Dottie::Shell) }

  # Mocks
  let(:parser) { class_double('Dottie::Dotfile').as_stubbed_const }
  let(:dotfile) { instance_double('Dottie::Dotfile') }

  it 'should install a local profile' do
    expect(parser).to receive(:from_profile).with(profile_at('/home/profiles/test'), anything).and_return(dotfile)
    expect(dotfile).to receive(:shells).and_return({})
    expect(dotfile).to receive(:post_install?).and_return(false)

    subject.run('/home/profiles/test')
  end

  it 'should skip installing a local profile that was already installed' do
    config.add_profile(Dottie::Models::Profile.new(location: '/home/profiles/test'))

    expect(parser).not_to receive(:from_profile)
    expect(dotfile).not_to receive(:shells)

    subject.run('/home/profiles/test')
  end

  it 'should install a profile from a remote repo' do
    expect(parser).to receive(:from_profile)
      .with(profile_at('/home/dottie/repos/git/test'), anything)
      .and_return(dotfile)
    expect(git).to receive(:clone).with(instance_of(Dottie::Models::Repo), '/home/dottie/repos/git')
    expect(dotfile).to receive(:shells).and_return({})
    expect(dotfile).to receive(:post_install?).and_return(false)

    subject.run('test', url: 'git')
  end

  it 'should install a profile from a remote repo that was already cloned' do
    config.add_repo(Dottie::Models::Repo.from_git('git'))

    expect(parser).to receive(:from_profile)
      .with(profile_at('/home/dottie/repos/git/test'), anything)
      .and_return(dotfile)
    expect(git).not_to receive(:clone)
    expect(dotfile).to receive(:shells).and_return({})
    expect(dotfile).to receive(:post_install?).and_return(false)

    subject.run('test', url: 'git')
  end

  it 'should skip installing a profile from a remote repo that was already installed' do
    repo = Dottie::Models::Repo.from_git('git')
    config.add_repo(repo)
    profile = Dottie::Models::Profile.new(location: '/home/dottie/repos/git/test', repo_id: repo.id)
    config.add_profile(profile)

    expect(parser).not_to receive(:from_profile)
    expect(git).not_to receive(:clone)
    expect(dotfile).not_to receive(:shells)

    subject.run('test', url: 'git')
  end

  it 'should save installed repos and profiles to the config file' do
    expect(parser).to receive(:from_profile)
      .with(profile_at('/home/dottie/repos/git/test'), anything)
      .and_return(dotfile)
    expect(git).to receive(:clone).with(instance_of(Dottie::Models::Repo), '/home/dottie/repos/git')
    expect(dotfile).to receive(:shells).and_return(
      {
        common: Dottie::Models::ShellSettings.new(
          [{}],
          { test: 'true' }
        )
      }
    )
    expect(dotfile).to receive(:post_install?).and_return(false)

    subject.run('test', url: 'git')

    saved_config = storage.load_model(Dottie::Models::Config)
    expect(saved_config.repo('git')).to have_attributes(url: 'git')
    expect(saved_config.profile('_home_dottie_repos_git_test')).to \
      have_attributes(location: '/home/dottie/repos/git/test', repo_id: 'git')
    expect(saved_config.shell_settings(:common).commands.size).to be(1)
    expect(saved_config.shell_settings(:common).environment_vars).to include(test: 'true')
  end
end
