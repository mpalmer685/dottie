# frozen_string_literal: true

require 'rspec'
require 'dottie/resetter'

files = {
  'home': {
    'config': {
      'dottie': {
        'dottie_config.yml': "---\n:dotfile_path: \"/home/dottie\""
      }
    },
    'dottie': {
      'profiles': {}
    }
  }
}

describe Dottie::Resetter do
  subject { Dottie::Resetter.new(file_system, os) }
  let(:file_system) { SpecHelper::FileSystem.new.use(files) }
  let(:os) { SpecHelper::OS.new.use(:macos, '/home/config') }

  it 'should delete the dotfiles folder and the config folder' do
    subject.reset
    expect(file_system.exist?('/home/config/dottie')).to be(false)
    expect(file_system.exist?('/home/config')).to be(true)
    expect(file_system.exist?('/home/dottie')).to be(false)
  end
end
