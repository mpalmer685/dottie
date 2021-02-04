# frozen_string_literal: true

require 'dottie/commands/reset'
require 'dottie/logger'

files = {
  home: {
    config: {
      dottie: {
        'dottie_config.yml': "---\ndotfile_path: /home/dottie"
      }
    },
    dottie: {
      profiles: {}
    }
  }
}

describe Dottie::Commands::Reset do
  subject { Dottie::Commands::Reset.new(file_system, os, logger, prompt) }
  let(:file_system) { SpecHelper::FileSystem.new.use(files) }
  let(:os) { SpecHelper::OS.new.use(:macos, '/home/config') }
  let(:logger) { Dottie::Logger.silent }
  let(:prompt) { object_double(TTY::Prompt.new) }

  it 'should exit early if the user cancels at the prompt' do
    allow(prompt).to receive(:no?).and_return(true)

    subject.run

    expect(file_system.exist?('/home/config/dottie')).to be(true)
    expect(file_system.exist?('/home/dottie')).to be(true)
  end

  it 'should delete the dotfiles folder and the config folder' do
    allow(prompt).to receive(:no?).and_return(false)

    subject.run

    expect(file_system.exist?('/home/config/dottie')).to be(false)
    expect(file_system.exist?('/home/config')).to be(true)
    expect(file_system.exist?('/home/dottie')).to be(false)
  end
end
