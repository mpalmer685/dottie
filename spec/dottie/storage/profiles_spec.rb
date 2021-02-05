# frozen_string_literal: true

require 'dottie/models/config'
require 'dottie/models/profiles_settings'
require 'dottie/models/repo'
require 'dottie/storage/profiles'

files = {
  home: {
    dottie: {
      profiles: {},
      repos: {},
      shells: {}
    }
  }
}

describe Dottie::Storage::Profiles do
  subject { described_class.new(dottie_config, profiles_settings, file_system, logger) }
  let(:dottie_config) { Dottie::Models::Config.new('/home/dottie') }
  let(:profiles_settings) { Dottie::Models::ProfilesSettings.new }
  let(:file_system) { SpecHelper::FileSystem.new.use(files) }
  let(:logger) { Dottie::Logger.default }

  it 'should add a local profile' do
    file_system.add(
      {
        home: {
          profiles: {
            test: {
              Dotfile: ''
            }
          }
        }
      }
    )

    profile = subject.from_local('/home/profiles/test')
    expect(profile.repo_id).to be_nil
    expect(profile.source_path).to eql('/home/profiles/test')
    expect(profile.parent_id).to be_nil
    expect(profile.id).not_to be_nil
    expect(profiles_settings.profile(profile.id)).not_to be_nil
    expect(file_system.symlink?('/home/dottie/profiles/_home_profiles_test')).to be(true)
  end

  context 'when a local profile is already installed' do
    before :each do
      profiles_settings.add_profile(
        Dottie::Models::Profile.new(source_path: '/home/profiles/test', id: '_home_profiles_test')
      )

      file_system.add(
        {
          home: {
            dottie: {
              profiles: {
                _home_profiles_test: '@/home/profiles/test'
              }
            }
          }
        }
      )
    end

    it 'should use the existing symlink' do
      expect { subject.from_local('/home/profiles/test') }.not_to(
        change { file_system.symlink?('/home/dottie/profiles/_home_profiles_test') }
      )
    end

    it 'should use the existing profile' do
      expect { subject.from_local('/home/profiles/test') }.not_to(
        change { profiles_settings.profile('_home_profiles_test') }
      )
    end
  end

  it 'should add a remote profile' do
    profiles_settings.add_repo(
      Dottie::Models::Repo.from_definition({ 'url' => 'git' })
    )
    file_system.add(
      {
        home: {
          dottie: {
            repos: {
              git___: {
                profile: {
                  Dotfile: ''
                }
              }
            }
          }
        }
      }
    )

    profile = subject.from_repo('git___', 'profile')
    expect(profile.repo_id).to eql('git___')
    expect(profile.source_path).to eql('profile')
    expect(profile.parent_id).to be_nil
    expect(profile.id).not_to be_nil
    expect(profiles_settings.profile(profile.id)).not_to be_nil
    expect(file_system.symlink?('/home/dottie/profiles/git_____profile')).to be(true)
  end

  context 'when a remote profile is already installed' do
    before :each do
      profiles_settings.add_repo(
        Dottie::Models::Repo.from_definition({ 'url' => 'git' })
      )
      profiles_settings.add_profile(
        Dottie::Models::Profile.new(
          repo_id: 'git___',
          source_path: 'profile',
          id: 'git_____profile'
        )
      )
      file_system.add(
        {
          home: {
            dottie: {
              repos: {
                git___: {
                  profile: {
                    Dotfile: ''
                  }
                }
              },
              profiles: {
                git_____profile: '@/home/dottie/repos/git___/profile'
              }
            }
          }
        }
      )
    end

    it 'should use the existing symlink' do
      expect { subject.from_repo('git___','profile') }.not_to(
        change { file_system.symlink?('/home/dottie/profiles/git_____profile') }
      )
    end

    it 'should use the existing profile' do
      expect { subject.from_repo('git___','profile') }.not_to(
        change { profiles_settings.profile('git_____profile') }
      )
    end
  end

  it 'should return a previously installed remote profile' do


    profile = subject.from_local('/home/profiles/test')
    expect(profile.repo_id).to be_nil
    expect(profile.source_path).to eql('/home/profiles/test')
    expect(profile.parent_id).to be_nil
    expect(profile.id).not_to be_nil
    expect(profiles_settings.profile(profile.id)).not_to be_nil
    expect(file_system.symlink?('/home/dottie/profiles/_home_profiles_test')).to be(true)
  end
end
