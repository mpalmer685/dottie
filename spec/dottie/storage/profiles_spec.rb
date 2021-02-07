# frozen_string_literal: true

require 'dottie/models/config'
require 'dottie/models/profiles_settings'
require 'dottie/models/repo'
require 'dottie/storage/profiles'

files = {
  home: {
    dottie: {
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
  let(:logger) { Dottie::Logger.silent }

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

    profile = subject.install_from_local('/home/profiles/test')
    expect(profile.repo_id).to be_nil
    expect(profile.source_path).to eql('/home/profiles/test')
    expect(profile.parent_id).to be_nil
    expect(profile.id).not_to be_nil
    expect(profiles_settings.profile(profile.id)).to be == profile
  end

  context 'when a local profile is already installed' do
    before :each do
      profiles_settings.add_profile(
        Dottie::Models::Profile.new(source_path: '/home/profiles/test', id: '_home_profiles_test')
      )
    end

    it 'should use the existing profile' do
      expect { subject.install_from_local('/home/profiles/test') }.not_to(
        change { profiles_settings.profile('_home_profiles_test') }
      )
    end
  end

  it 'should add a remote profile' do
    profiles_settings.add_repo(Dottie::Models::Repo.from_git('git'))
    file_system.add(
      {
        home: {
          dottie: {
            repos: {
              git: {
                profile: {
                  Dotfile: ''
                }
              }
            }
          }
        }
      }
    )

    profile = subject.install_from_repo('git', 'profile')
    expect(profile.repo_id).to eql('git')
    expect(profile.source_path).to eql('profile')
    expect(profile.parent_id).to be_nil
    expect(profile.id).not_to be_nil
    expect(profiles_settings.profile(profile.id)).not_to be_nil
  end

  context 'when a remote profile is already installed' do
    before :each do
      profiles_settings.add_repo(Dottie::Models::Repo.from_git('git'))
      profiles_settings.add_profile(
        Dottie::Models::Profile.new(
          repo_id: 'git',
          source_path: 'profile',
          id: 'git__profile'
        )
      )
      file_system.add(
        {
          home: {
            dottie: {
              repos: {
                git: {
                  profile: {
                    Dotfile: ''
                  }
                }
              }
            }
          }
        }
      )
    end

    it 'should use the existing profile' do
      expect { subject.install_from_repo('git','profile') }.not_to(
        change { profiles_settings.profile('git__profile') }
      )
    end
  end

  it 'should uninstall an installed profile' do
    profiles_settings.add_profile(
      Dottie::Models::Profile.new(source_path: '/home/profiles/test', id: '_home_profiles_test')
    )

    subject.uninstall('_home_profiles_test')
    expect(profiles_settings.profile('_home_profiles_test')).to be_nil
  end
end
