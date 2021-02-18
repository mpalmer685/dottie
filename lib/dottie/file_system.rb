# frozen_string_literal: true

require 'dottie/shell'

module Dottie
  class FileSystem
    def initialize(shell = Dottie::Shell.new)
      @shell = shell
    end

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

      raise "Could not create directory #{path}" if @shell.run!('mkdir -p', path).failure?
    end

    def read_file(path)
      return File.read(path) if file?(path)

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

    def delete(path, recursive: false)
      args = ['-f']
      args << '-R' if recursive
      args << path

      raise "Could not delete #{path}" if @shell.run!('rm', *args).failure?
    end
  end
end
