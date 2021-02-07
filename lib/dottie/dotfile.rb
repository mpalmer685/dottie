# frozen_string_literal: true

require 'dottie/dotfile/dsl'

module Dottie
  class Dotfile
    include Dottie::Dotfile::DSL

    Shell = Struct.new(:commands, :environment_vars)

    class Entry
      attr_reader :type, :options

      def initialize(type, options = {})
        @type = type
        @options = options
      end
    end

    def initialize(profile_path, file_system, &block)
      @profile_path = profile_path
      @file_system = file_system
      @shells = {}

      instance_eval(&block) if block
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
