# frozen_string_literal: true

require 'dottie/dotfile/dsl'
require 'dottie/dotfile/post_install_hooks'

module Dottie
  class Dotfile
    attr_reader :shells

    include Dottie::Dotfile::DSL
    include Dottie::Dotfile::PostInstallHooks

    Shell = Struct.new(:commands, :environment_vars)

    class Entry
      attr_reader :type, :options

      def initialize(type, options = {})
        @type = type
        @options = options
      end
    end

    def self.from_profile(
      profile_path,
      file_system = Dottie::FileSystem.new,
      shell = Dottie::Shell.new,
      logger = Dottie::Logger.default
    )
      dotfile_path = File.join(profile_path, 'Dotfile')
      raise "No Dotfile found in #{profile_path}" unless file_system.file?(dotfile_path)

      contents = file_system.read_file(dotfile_path)

      new(profile_path, file_system, shell, logger) do
        # rubocop:disable Security/Eval
        eval(contents, nil, dotfile_path)
        # rubocop:enable Security/Eval
      end
    end

    def initialize(profile_path, file_system, shell, logger, &block)
      @profile_path = profile_path
      @file_system = file_system
      @shell = shell
      @logger = logger
      @shells = {}

      return unless block

      begin
        instance_eval(&block)
      rescue Exception => e # rubocop:disable Lint/RescueException
        error_msg = "Invalid Dotfile: #{e.message}"
        raise RuntimeError, error_msg, e.backtrace
      end
    end

    def commands(shell_type)
      @shells[shell_type]&.commands || []
    end

    def environment_vars(shell_type)
      @shells[shell_type]&.environment_vars || {}
    end

    def post_install?
      !@post_install_callback.nil?
    end

    def post_install!
      if @post_install_callback
        @post_install_callback.call
        true
      else
        false
      end
    end

    private

    def full_file_path(file_path)
      File.join @profile_path, file_path
    end
  end
end
