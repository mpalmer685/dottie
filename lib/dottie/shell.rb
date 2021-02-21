# frozen_string_literal: true

require 'tty-command'

module Dottie
  class Shell
    def initialize(cmd = TTY::Command.new(printer: :quiet))
      @cmd = cmd
    end

    def run(command, *args, silent: false, cwd: nil, **opts)
      @cmd.run(command, *args, config(opts, silent, cwd))
    end

    def run!(command, *args, silent: false, cwd: nil, **opts)
      @cmd.run!(command, *args, config(opts, silent, cwd))
    end

    def sudo(command, *args, silent: false, cwd: nil, **opts)
      opts[:user] = 'root'
      @cmd.run(command, *args, config(opts, silent, cwd))
    end

    def sudo!(command, *args, silent: false, cwd: nil, **opts)
      opts[:user] = 'root'
      @cmd.run!(command, *args, config(opts, silent, cwd))
    end

    def exec_file(path, silent: false, **opts)
      @cmd.run('sh', path, config(opts, silent, nil))
    end

    def exec_file!(path, silent: false, **opts)
      @cmd.run!('sh', path, config(opts, silent, nil))
    end

    def command_exists?(command)
      run!('type', command, silent: true).success?
    end

    private

    def config(opts, silent, cwd)
      opts[:chdir] = File.expand_path(cwd) unless cwd.nil?
      opts[:out] = opts[:err] = '/dev/null' if silent
      opts
    end
  end
end
