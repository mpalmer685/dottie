# frozen_string_literal: true

describe Dottie::Models::Config do
  let(:repo) { Dottie::Models::Repo.from_git('git') }
  let(:profile) { Dottie::Models::Profile.new(location: '/home/profiles/test') }

  it 'should add a repo to an empty collection' do
    config = described_class.new
    config.add_repo(repo)

    expect(config.repos).not_to be_nil
    expect(config.repos[repo.id]).to eql(repo)
  end

  it 'should add a repo to an existing collection' do
    existing_repo = Dottie::Models::Repo.from_git('existing_git')
    repos = { existing_repo.id => existing_repo }
    config = described_class.new(repos: repos)
    config.add_repo(repo)

    expect(config.repos[existing_repo.id]).to eql(existing_repo)
    expect(config.repos[repo.id]).to eql(repo)
  end

  it 'should return a repo by ID' do
    config = described_class.new
    config.add_repo(repo)

    expect(config.repo(repo.id)).to eql(repo)
  end

  it 'should add a profile to an empty collection' do
    config = described_class.new
    config.add_profile(profile)

    expect(config.profiles).not_to be_nil
    expect(config.profiles[profile.id]).to eql(profile)
  end

  it 'should add a profile to an existing collection' do
    existing_profile = Dottie::Models::Profile.new(location: '/home/profiles/common')
    profiles = { existing_profile.id => existing_profile }
    config = described_class.new(profiles: profiles)
    config.add_profile(profile)

    expect(config.profiles[existing_profile.id]).to eql(existing_profile)
    expect(config.profiles[profile.id]).to eql(profile)
  end

  it 'should return a profile by ID' do
    config = described_class.new
    config.add_profile(profile)

    expect(config.profile(profile.id)).to eql(profile)
  end

  it 'should add shell settings for a new shell type'

  it 'should merge shell settings for an existing shell type'

  it 'should return shell settings by shell type'
end
