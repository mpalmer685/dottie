# frozen_string_literal: true

require 'tty-command'

module Dottie
  class Shell
    def initialize
      @cmd = TTY::Command.new(printer: Printer)
    end

    def run(command, *args, silent: false, cwd: nil, **opts)
      @cmd.printer.silent = silent
      result = @cmd.run(command, *args, config(opts, cwd))
      yield if block_given? && result.success?
      result
    ensure
      @cmd.printer.silent = false
    end

    def run!(command, *args, silent: false, cwd: nil, **opts)
      @cmd.printer.silent = silent
      result = @cmd.run!(command, *args, config(opts, cwd))
      yield if block_given? && result.success?
      result
    ensure
      @cmd.printer.silent = false
    end

    def sudo(command, *args, silent: false, cwd: nil, **opts)
      @cmd.printer.silent = silent
      opts[:user] = 'root'
      result = @cmd.run(command, *args, config(opts, cwd))
      yield if block_given? && result.success?
      result
    ensure
      @cmd.printer.silent = false
    end

    def sudo!(command, *args, silent: false, cwd: nil, **opts)
      @cmd.printer.silent = silent
      opts[:user] = 'root'
      result = @cmd.run!(command, *args, config(opts, cwd))
      yield if block_given? && result.success?
      result
    ensure
      @cmd.printer.silent = false
    end

    def exec_file(path, silent: false, **opts)
      @cmd.printer.silent = silent
      result = @cmd.run('sh', path, config(opts, nil))
      yield if block_given? && result.success?
      result
    ensure
      @cmd.printer.silent = false
    end

    def exec_file!(path, silent: false, **opts)
      @cmd.printer.silent = silent
      result = @cmd.run!('sh', path, config(opts, nil))
      yield if block_given? && result.success?
      result
    ensure
      @cmd.printer.silent = false
    end

    def command_exists?(command)
      run!('type', command, silent: true).success?
    end

    private

    def config(opts, cwd)
      opts[:chdir] = File.expand_path(cwd) unless cwd.nil?
      opts
    end

    class Printer < TTY::Command::Printers::Abstract
      attr_accessor :silent

      def initialize(*)
        super
        @silent = false
      end

      def print_command_start(cmd, *args)
        message = ["Running #{decorate(cmd.to_command, :yellow, :bold)}"]
        message << args.map(&:chomp).join(' ') unless args.empty?
        write(cmd, message.join)
      end

      def print_command_out_data(cmd, *args)
        message = args
                  .map(&:chomp)
                  .join(' ')
                  .split("\n")
                  .map(&method(:indent))
                  .join("\n")
        write(cmd, message, out_data)
      end

      def print_command_err_data(cmd, *args)
        message = args
                  .map(&:chomp)
                  .join(' ')
                  .split("\n")
                  .map(&method(:indent))
                  .join("\n")
        write(cmd, '  ' + decorate(message, :red), err_data)
      end

      def print_command_exit(cmd, status, *_)
        unless !cmd.only_output_on_error || status.zero?
          output << out_data
          output << err_data
        end
      end

      def write(cmd, message, data = nil)
        return if silent

        target = cmd.only_output_on_error && !data.nil? ? data : output
        target << message + "\n"
      end

      private

      def indent(line)
        '  ' + line
      end
    end
  end
end
