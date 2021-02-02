# frozen_string_literal: true

require 'open3'

module Dottie
  class Shell
    def self.shell(command, silent: false)
      exit_code = nil
      stdout = ''
      stdout_line = '  '
      stderr = ''
      stderr_line = '  '
      Open3.popen3(command) do |_, o, e, t|
        stdout_open = true
        stderr_open = true
        while stdout_open || stderr_open
          if stdout_open
            stdout_open = read_stream o, stderr_open do |char|
              stdout.insert(-1, char)
              stdout_line = update_output(char, stdout_line, STDOUT) unless silent
            end
          end

          next unless stderr_open

          stderr_open = read_stream e, stdout_open do |char|
            stderr.insert(-1, char)
            stderr_line = update_output(char, stderr_line, STDERR) unless silent
          end
        end
        exit_code = t.value
      end
      [exit_code, stdout.strip, stderr]
    end

    class << self
      private

      def read_stream(stream, skip_wait, &block)
        stream_open = true
        begin
          ch = stream.read_nonblock(1)
          block.call(ch)
        rescue IO::WaitReadable
          IO.select([stream], nil, nil, 0.01) unless skip_wait
        rescue EOFError
          stream_open = false
        end
        stream_open
      end

      def update_output(char, output, output_stream)
        output.insert(-1, char)
        if char == "\n"
          output_stream.puts output
          output = '  '
        end
        output
      end
    end
  end
end
