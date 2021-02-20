# frozen_string_literal: true

require 'tty-command'

module Dottie
  class Shell
    def initialize(cmd = TTY::Command.new(printer: :quiet))
      @cmd = cmd
    end

    def run(command, *args, silent: false, cwd: nil, **opts)
      opts[:chdir] = File.expand_path(cwd) unless cwd.nil?
      opts[:out] = opts[:err] = '/dev/null' if silent
      @cmd.run(command, *args, opts)
    end

    def run!(command, *args, silent: false, cwd: nil, **opts)
      opts[:chdir] = File.expand_path(cwd) unless cwd.nil?
      opts[:out] = opts[:err] = '/dev/null' if silent
      @cmd.run!(command, *args, opts)
    end

    def command_exists?(command)
      run!('type', command, silent: true).success?
    end
  end
end
