# frozen_string_literal: true

module SpecHelper
  class FileSystem
    def initialize
      @files = {}
    end

    def use(files)
      @files = deep_copy files
      self
    end

    def exist?(path)
      !get_from_path(path).nil?
    end

    def file?(path)
      get_from_path(path).is_a? String
    end

    def directory?(path)
      get_from_path(path).is_a? Hash
    end

    def empty?(path)
      directory?(path) && get_from_path(path).empty?
    end

    def mkdir(path)
      current_folder = @files
      path_segments(path).each do |segment|
        current_folder[segment] = current_folder[segment] || {}
        current_folder = current_folder[segment]
      end
    end

    def read_file(path)
      raise Exception "#{path} does not exist" unless exist?(path)
      raise Exception "#{path} is not a file" unless file?(path)

      get_from_path path
    end

    def write_file(path, content)
      segments = path_segments path
      directory = @files.dig(*segments[0...-1])
      directory[segments.last] = content
    end

    private

    def get_from_path(path)
      @files.dig(*path_segments(path))
    end

    def path_segments(path)
      path.gsub(%r{^/}, '').split('/').map(&:to_sym)
    end

    def deep_copy(hash)
      Marshal.load(Marshal.dump(hash))
    end
  end
end
