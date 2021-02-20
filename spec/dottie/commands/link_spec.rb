# frozen_string_literal: true

require 'dottie/commands/link'

files = {
  home: {
    dottie: {
      shells: {}
    }
  }
}

describe Dottie::Commands::Link do
  subject { described_class.new(model_storage, file_system, Dottie::Logger.silent) }

  let(:file_system) { SpecHelper::FileSystem.new.use(files) }
  let(:os) { SpecHelper::OS.new.use(:macos, '/home/config') }
  let(:model_storage) do
    storage = Dottie::Storage.new(file_system, os)
    storage.config = Dottie::Models::Config.new(dotfile_path: '/home/dottie')
    storage.exec_cache = Dottie::Models::ExecCache.new
    storage
  end

  it 'should create a symlink to the shell file' do
    file_system.add(
      {
        home: {
          dottie: {
            shells: {
              'bash.sh': 'test file'
            }
          }
        }
      }
    )

    subject.run(:bash, '/home/.bashrc')

    expect(file_system.symlink?('/home/.bashrc')).to be(true)
    expect(file_system.symlink_path('/home/.bashrc')).to eq('/home/dottie/shells/bash.sh')
  end

  it 'should raise an error if the shell file has not been generated' do
    expect { subject.run(:bash, '/home/.bashrc') }.to raise_error(/has not been generated/i)
  end

  it 'should raise an error if a file already exists at the destination' do
    file_system.add(
      {
        home: {
          '.bashrc': 'existing file',
          dottie: {
            shells: {
              'bash.sh': 'test file'
            }
          }
        }
      }
    )

    expect { subject.run(:bash, '/home/.bashrc') }.to raise_error(/file already exists/i)
  end

  it 'should raise an error if the destination is already a symlink' do
    file_system.add(
      {
        home: {
          '.bashrc': '@/home/other/file',
          dottie: {
            shells: {
              'bash.sh': 'test file'
            }
          }
        }
      }
    )

    expect { subject.run(:bash, '/home/.bashrc') }.to raise_error(/is already a symlink/i)
  end

  it 'should not raise an error if the --force flag is passed' do
    file_system.add(
      {
        home: {
          '.bashrc': '@/home/other/file',
          dottie: {
            shells: {
              'bash.sh': 'test file'
            }
          }
        }
      }
    )

    expect { subject.run(:bash, '/home/.bashrc', force: true) }.not_to raise_error
  end

  it 'should not raise an error if the symlink already points to the shell file' do
    file_system.add(
      {
        home: {
          '.bashrc': '@/home/dottie/shells/bash.sh',
          dottie: {
            shells: {
              'bash.sh': 'test file'
            }
          }
        }
      }
    )

    expect { subject.run(:bash, '/home/.bashrc') }.not_to raise_error
  end
end
