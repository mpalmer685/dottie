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

    def add(files)
      @files = merge_recursively(@files, files)
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
      raise "#{path} does not exist" unless exist?(path)
      raise "#{path} is not a file" unless file?(path)

      get_from_path path
    end

    def write_file(path, content)
      segments = path_segments path
      directory = @files.dig(*segments[0...-1])
      directory[segments.last] = content
    end

    def delete_file(path)
      raise "#{path} is not a file" unless file?(path)

      segments = path_segments path
      directory = @files.dig(*segments[0...-1])
      directory.delete(segments.last)
    end

    def delete_directory(path)
      raise "#{path} is not a directory" unless directory?(path)

      segments = path_segments path
      directory = @files.dig(*segments[0...-1])
      directory.delete(segments.last)
    end

    def symlink?(path)
      file?(path) && get_from_path(path).start_with?('@')
    end

    def symlink_path(symlink)
      read_file(symlink).gsub(/^@/, '')
    end

    def symlink(from, to)
      write_file(from, "@#{to}")
    end

    def unlink(path)
      delete_file(path)
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

    def merge_recursively(target, source)
      target.merge(source) do |_, target_item, source_item|
        if target_item.is_a?(Hash) || source_item.is_a?(Hash)
          merge_recursively(target_item, source_item)
        else
          source_item || target_item
        end
      end
    end
  end
end
