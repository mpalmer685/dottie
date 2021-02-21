# frozen_string_literal: true

require 'dottie/models/exec_cache'
require 'dottie/models/profile'

describe Dottie::Models::ExecCache do
  subject { described_class.new }

  let(:profile) { Dottie::Models::Profile.new(location: '/home/profiles/test') }
  let(:command) { 'ls -a' }

  it 'should add a command when empty' do
    subject.add_command(profile, command)

    expect(subject.profiles[profile.id].size).to be(1)
  end

  it 'should add a command for a new profile' do
    subject.profiles = {
      test: ['test']
    }
    subject.add_command(profile, command)

    expect(subject.profiles.size).to be(2)
    expect(subject.profiles[profile.id].size).to be(1)
  end

  it 'should add a command for an existing profile' do
    subject.profiles = {
      profile.id => ['test']
    }
    subject.add_command(profile, command)

    expect(subject.profiles[profile.id].size).to be(2)
  end

  it 'should return whether a command has already been run' do
    subject.add_command(profile, command)

    new_profile = Dottie::Models::Profile.new(location: '/profiles')

    expect(subject.contain?(profile, command)).to be(true)
    expect(subject.contain?(profile, 'test')).to be(false)
    expect(subject.contain?(new_profile, command)).to be(false )
  end
end
