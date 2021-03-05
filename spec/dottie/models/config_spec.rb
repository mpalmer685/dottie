# frozen_string_literal: true

describe Dottie::Models::Config do
  let(:repo) { Dottie::Models::Repo.from_git('git') }
  let(:profile) { Dottie::Models::Profile.new(location: '/home/profiles/test') }
  let(:shell_settings) do
    commands = [
      {
        type: :source,
        options: {
          path: '/home/test.sh'
        }
      }
    ]
    env = { test: 'true' }
    Dottie::Models::ShellSettings.new(commands, env)
  end

  it 'should add a repo to an empty collection' do
    config = described_class.new
    config.add_repo(repo)

    expect(config.repo(repo.id)).to eq(repo)
  end

  it 'should add a repo to an existing collection' do
    existing_repo = Dottie::Models::Repo.from_git('existing_git')
    repos = { existing_repo.id => existing_repo }
    config = described_class.new(repos: repos)
    config.add_repo(repo)

    expect(config.repo(existing_repo.id)).to eq(existing_repo)
    expect(config.repo(repo.id)).to eq(repo)
  end

  it 'should return a repo by ID' do
    config = described_class.new
    config.add_repo(repo)

    expect(config.repo(repo.id)).to eq(repo)
  end

  it 'should return nil for a repo ID that does not exist' do
    config = described_class.new
    expect(config.repo(repo.id)).to be_nil
  end

  it 'should add a profile to an empty collection' do
    config = described_class.new
    config.add_profile(profile)

    expect(config.profile(profile.id)).to eq(profile)
  end

  it 'should add a profile to an existing collection' do
    existing_profile = Dottie::Models::Profile.new(location: '/home/profiles/common')
    profiles = { existing_profile.id => existing_profile }
    config = described_class.new(profiles: profiles)
    config.add_profile(profile)

    expect(config.profile(existing_profile.id)).to eq(existing_profile)
    expect(config.profile(profile.id)).to eq(profile)
  end

  it 'should return a profile by ID' do
    config = described_class.new
    config.add_profile(profile)

    expect(config.profile(profile.id)).to eq(profile)
  end

  it 'should return nil for a profile ID that does not exist' do
    config = described_class.new
    expect(config.profile(profile.id)).to be_nil
  end

  it 'should return shell settings by shell type' do
    profile.add_shell(:common, shell_settings)

    config = described_class.new
    config.add_profile(profile)

    expect(config.shell_settings(:common)).to eq(shell_settings)
  end

  it 'should return empty shell settings for a shell type that was not defined' do
    config = described_class.new

    settings = config.shell_settings(:common)
    expect(settings.commands.size).to be(0)
    expect(settings.environment_vars.size).to be(0)
  end
end
