# frozen_string_literal: true

require 'dottie/dotfile'

module Dottie
  files = {
    home: {
      profiles: {
        test: {
          bin: {},
          'test.sh': 'file content'
        }
      }
    }
  }

  describe Dottie::Dotfile::DSL do
    let(:profile) { Dottie::Models::Profile.new(location: '/home/profiles/test') }
    let(:exec_cache) { Dottie::Models::ExecCache.new }
    let(:file_system) { SpecHelper::FileSystem.new.use(files) }
    let(:os) { SpecHelper::OS.new.use(:macos, '/home/config') }
    let(:shell) { instance_double(Dottie::Shell) }
    let(:logger) { Dottie::Logger.silent }

    it 'should allow a user to define commands for a specific shell' do
      dotfile = Dotfile.new(profile, exec_cache, file_system, os, shell, logger) do
        shell :bash do
          source 'test.sh'
        end
      end
      expect(dotfile.commands(:bash).size).to be == 1
    end

    it 'should allow a user to define commands for different shells' do
      dotfile = Dotfile.new(profile, exec_cache, file_system, os, shell, logger) do
        shell do
          source 'test.sh'
        end

        shell :bash do
          path_add 'bin'
        end
      end

      expect(dotfile.commands(:bash).size).to be == 1
      expect(dotfile.commands(:common).size).to be == 1
    end

    it 'should raise an error if a shell is defined more than once' do
      expect do
        Dotfile.new(profile, exec_cache, file_system, os, shell, logger) do
          shell :bash do
            source 'test.sh'
          end

          shell :bash do
            path_add 'bin'
          end
        end
      end.to raise_error(RuntimeError)
    end

    it 'should raise an error if no block is defined' do
      expect do
        Dotfile.new(profile, exec_cache, file_system, os, shell, logger) do
          shell
        end
      end.to raise_error(RuntimeError)
    end

    describe 'source command' do
      it 'should support the source command' do
        dotfile = Dotfile.new(profile, exec_cache, file_system, os, shell, logger) do
          shell do
            source 'test.sh'
          end
        end
        expect(dotfile.commands(:common)[0].options[:path]).to eql('/home/profiles/test/test.sh')
      end

      it 'should throw an error when given an invalid argument' do
        expect do
          Dotfile.new(profile, exec_cache, file_system, os, shell, logger) do
            shell do
              source 1
            end
          end
        end.to raise_error(RuntimeError)
      end

      it 'should throw an error if the file does not exist' do
        expect do
          Dotfile.new(profile, exec_cache, file_system, os, shell, logger) do
            shell do
              source 'missing'
            end
          end
        end.to raise_error(RuntimeError)
      end

      it 'should throw an error if the given path is a directory' do
        expect do
          Dotfile.new(profile, exec_cache, file_system, os, shell, logger) do
            shell do
              source 'bin'
            end
          end
        end.to raise_error(RuntimeError)
      end
    end

    describe 'path_add command' do
      it 'should support the path_add command' do
        dotfile = Dotfile.new(profile, exec_cache, file_system, os, shell, logger) do
          shell do
            path_add 'bin'
          end
        end
        expect(dotfile.commands(:common)[0].options[:path]).to eql('/home/profiles/test/bin')
      end

      it 'should support adding a path in the home folder' do
        dotfile = Dotfile.new(profile, exec_cache, file_system, os, shell, logger) do
          shell do
            path_add '~/bin'
          end
        end
        expect(dotfile.commands(:common)[0].options[:path]).to eql("#{ENV['HOME']}/bin")
      end

      it 'should throw an error when given an invalid argument' do
        expect do
          Dotfile.new(profile, exec_cache, file_system, os, shell, logger) do
            shell do
              path_add 1
            end
          end
        end.to raise_error(RuntimeError)
      end
    end

    describe 'fpath_add command' do
      it 'should support the fpath_add command' do
        dotfile = Dotfile.new(profile, exec_cache, file_system, os, shell, logger) do
          shell do
            fpath_add 'bin'
          end
        end
        expect(dotfile.commands(:common)[0].options[:path]).to eql('/home/profiles/test/bin')
      end

      it 'should throw an error when given an invalid argument' do
        expect do
          Dotfile.new(profile, exec_cache, file_system, os, shell, logger) do
            shell do
              fpath_add 1
            end
          end
        end.to raise_error(RuntimeError)
      end
    end

    describe 'env command' do
      it 'should support the env command' do
        dotfile = Dotfile.new(profile, exec_cache, file_system, os, shell, logger) do
          shell do
            env VAR_1: 'test_1',
                VAR_2: 'test_2'
          end
        end
        expect(dotfile.environment_vars(:common)).to include(VAR_1: 'test_1', VAR_2: 'test_2')
      end

      it 'should merge variables when called multiple times' do
        dotfile = Dotfile.new(profile, exec_cache, file_system, os, shell, logger) do
          shell do
            env VAR_1: 'test_1'
            env VAR_2: 'test_2'
          end
        end
        expect(dotfile.environment_vars(:common)).to include(VAR_1: 'test_1', VAR_2: 'test_2')
      end

      it 'should throw an error when given an invalid argument' do
        expect do
          Dotfile.new(profile, exec_cache, file_system, os, shell, logger) do
            shell do
              env 1
            end
          end
        end.to raise_error(RuntimeError)
      end
    end

    describe 'post_install' do
      it 'should allow the user to define a post-install hook' do
        yielded = nil
        Dotfile.new(profile, exec_cache, file_system, os, shell, logger) do
          post_install do
            yielded = :dottie
          end
        end.post_install!
        expect(yielded).to eq(:dottie)
      end

      it 'should allow the user to define other functions that can be called from the post-install hook' do
        yielded = nil
        Dotfile.new(profile, exec_cache, file_system, os, shell, logger) do
          def dottie
            :dottie
          end

          post_install do
            yielded = dottie
          end
        end.post_install!
        expect(yielded).to eq(:dottie)
      end
    end
  end
end
