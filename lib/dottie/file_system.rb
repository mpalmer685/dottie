# frozen_string_literal: true

require 'dottie/shell'

module Dottie
  class FileSystem
    class << self
      def exist?(path)
        file?(path) || directory?(path)
      end

      def file?(path)
        File.file?(path) && File.readable?(path)
      end

      def directory?(path)
        Dir.exist? path
      end

      def empty?(path)
        Dir.empty? path
      end

      def mkdir(path)
        return if directory?(path)

        exit_code, output, = shell "mkdir -p \"#{path}\" 2>&1"
        raise "Could not create directory #{path}: #{output}" unless exit_code.success?
      end

      def read_file(path)
        return File.read(path) if file?(file)

        raise "Unable to read file at #{path}"
      end

      def write_file(path, content)
        File.write path, content
      end

      def delete_file(path)
        delete path
      end

      def delete_directory(path)
        delete path, recursive: true
      end

      private

      def shell(command, silent: false)
        Dottie::Shell.shell(command, silent: silent)
      end

      def delete(path, recursive: false)
        recursive = recursive ? '-R ' : ''
        exit_code, output, = shell "rm #{recursive}-f \"#{path}\" 2>&1"

        raise "Could not delete #{path}: #{output}" unless exit_code.success?
      end
    end
  end
end
