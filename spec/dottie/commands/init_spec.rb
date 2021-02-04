# frozen_string_literal: true

require 'dottie/commands/init'
require 'dottie/logger'

files = {
  'home': {
    'config': {}
  }
}

describe Dottie::Commands::Init do
  subject { Dottie::Commands::Init.new(file_system, os, Dottie::Logger.silent) }
  let(:file_system) { SpecHelper::FileSystem.new.use(files) }
  let(:os) { SpecHelper::OS.new.use(:macos, '/home/config') }

  context 'when the dotfiles directory does not exist' do
    before do
      subject.init '/home/dottie'
    end

    it 'should create the folder structure in the dotfile dir' do
      expect(file_system.directory?('/home/dottie')).to be(true)
      expect(file_system.directory?('/home/dottie/repos')).to be(true)
      expect(file_system.directory?('/home/dottie/profiles')).to be(true)
      expect(file_system.directory?('/home/dottie/shells')).to be(true)
    end

    it 'should create the config folder' do
      expect(file_system.directory?('/home/config/dottie')).to be(true)
    end

    it 'should create the initial config files' do
      expect(file_system.file?('/home/config/dottie/dottie_config.yml')).to be(true)
      expect(file_system.file?('/home/config/dottie/profiles_settings.yml')).to be(true)
      expect(file_system.file?('/home/config/dottie/exec_cache.yml')).to be(true)
    end
  end

  context 'when the dotfiles directory already exists' do
    it 'should continue initialization when the directory is empty' do
      file_system.use(
        {
          'home': {
            'config': {},
            'dotfiles': {}
          }
        }
      )
      expect { subject.init '/home/dotfiles' }.not_to raise_error
    end

    it 'should raise an error when the directory is not empty' do
      file_system.use(
        {
          'home': {
            'config': {},
            'dotfiles': {
              'a_file': 'some file content'
            }
          }
        }
      )
      expect { subject.init '/home/dotfiles' }.to raise_error(RuntimeError)
    end
  end

  context 'when the config directory already exists' do
    it 'should continue initialization when the directory is empty' do
      file_system.use(
        {
          'home': {
            'config': {
              'dottie': {}
            }
          }
        }
      )
      expect { subject.init '/home/dotfiles' }.not_to raise_error
    end

    it 'should raise an error when the directory is not empty' do
      file_system.use(
        {
          'home': {
            'config': {
              'dottie': {
                'a_file': 'existing file'
              }
            }
          }
        }
      )
      expect { subject.init '/home/dotfiles' }.to raise_error(RuntimeError)
    end
  end
end

