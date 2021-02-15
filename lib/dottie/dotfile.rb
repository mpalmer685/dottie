# frozen_string_literal: true

require 'dottie/dotfile/dsl'

module Dottie
  class Dotfile
    attr_reader :shells

    include Dottie::Dotfile::DSL

    Shell = Struct.new(:commands, :environment_vars)

    class Entry
      attr_reader :type, :options

      def initialize(type, options = {})
        @type = type
        @options = options
      end
    end

    def self.from_profile(profile_path, file_system)
      dotfile_path = File.join(profile_path, 'Dotfile')
      raise "No Dotfile found in #{profile_path}" unless file_system.file?(dotfile_path)

      contents = file_system.read_file(dotfile_path)

      new(profile_path, file_system) do
        # rubocop:disable Security/Eval
        eval(contents, nil, dotfile_path)
        # rubocop:enable Security/Eval
      end
    end

    def initialize(profile_path, file_system, &block)
      @profile_path = profile_path
      @file_system = file_system
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

    private

    def full_file_path(file_path)
      File.join @profile_path, file_path
    end
  end
end
