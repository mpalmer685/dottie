# frozen_string_literal: true

require 'dottie/dotfile/profile_context'
require 'dottie/template'

module Dottie
  class Dotfile
    module PostInstallHooks
      # File System

      def symlink?(symlink)
        @file_system.symlink?(symlink)
      end

      def symlink_path(symlink)
        @file_system.symlink_path(symlink)
      end

      def symlink(to, from: nil)
        if from.nil?
          output_file_name = ".#{File.basename(to)}"
          from = File.join(ENV['HOME'], output_file_name)
        end
        @file_system.symlink(full_file_path(to), from)
      end

      def mkdir(path)
        dir_path = full_file_path(path)
        if @file_system.directory?(dir_path)
          info("#{decorate(dir_path, :bold)} already exists")
          return
        end

        @file_system.mkdir(full_file_path(path))
      end

      def copy(from, to)
        @file_system.copy(full_file_path(from), full_file_path(to))
      end

      def erb(file_location, output_path = nil)
        if output_path.nil?
          output_file_name = ".#{File.basename(file_location, '.erb')}"
          output_path = File.join(ENV['HOME'], output_file_name)
        end

        context = ProfileContext.new(@profile)
        output = Dottie::Template.new(@file_system).render(full_file_path(file_location), context)
        return if @file_system.file?(output_path) && @file_system.read_file(output_path) == output

        @file_system.write_file(output_path, output)
      end

      # Logging

      def self.define_logging_level(name)
        define_method(name) do |*msg|
          @logger.send(name, *msg)
        end
      end

      define_logging_level :info
      define_logging_level :success
      define_logging_level :warn
      define_logging_level :error

      def decorate(*args)
        @logger.decorate(*args)
      end

      # Shell

      def exec(cmd, once: false, silent: false)
        return if once && @exec_cache.contain?(@profile, cmd)

        @shell.run!(cmd, silent: silent, cwd: @profile.location) do
          @exec_cache.add_command(@profile, cmd)
        end.out.chomp
      end

      def sudo(cmd, once: false, silent: false)
        return if once && @exec_cache.contain?(@profile, cmd)

        @shell.sudo!(cmd, silent: silent, cwd: @profile.location) do
          @exec_cache.add_command(@profile, cmd)
        end.out.chomp
      end

      def exec_file(path, once: false, silent: false)
        file_location = full_file_path(path)
        return if once && @exec_cache.contain?(@profile, file_location)

        @shell.exec_file!(file_location, silent: silent) do
          @exec_cache.add_command(@profile, file_location)
        end
      end

      def command_exists?(command)
        @shell.command_exists?(command)
      end

      def brew_bundle(brewfile = 'Brewfile')
        return unless @os.macos?

        brewfile_path = full_file_path(brewfile)
        raise "No Brewfile at #{brewfile_path}." unless @file_system.file?(brewfile_path)

        install_homebrew unless command_exists?('brew')
        @logger.info("Installing brew dependencies from Brewfile at #{brewfile_path}")
        @shell.run('brew update')
        @shell.run('brew bundle', '--no-lock', '--file', brewfile_path)
      end

      def install_homebrew
        homebrew_install_location = 'https://raw.githubusercontent.com/Homebrew/install/master/install.sh'
        @logger.info('Homebrew has not been installed. Installing now.') do
          @shell.run(%(/bin/bash -c "$(curl -fsSL #{homebrew_install_location})"))
          @logger.success('Homebrew installed!')
        end
      end
    end
  end
end
