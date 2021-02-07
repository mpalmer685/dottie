# frozen_string_literal: true

module Dottie
  class Dotfile
    module DSL
      def shell(shell_type = :common)
        raise "Commands for #{shell_type} shell have already been defined." unless @shells[shell_type].nil?
        raise "No callback defined for #{shell_type} shell" unless block_given?

        @shell_entries = []
        @shell_env = {}
        yield
      ensure
        @shells[shell_type] = Shell.new(@shell_entries, @shell_env)
      end

      # @!group Shell DSL

      def source(relative_path)
        raise "Sourced file path (#{relative_path.inspect}) should be a String object" unless relative_path.is_a? String

        file_path = full_file_path relative_path
        raise "File does not exist at path #{file_path}" unless @file_system.exist?(file_path)
        raise "#{file_path} is not a file" unless @file_system.file?(file_path)

        @shell_entries << Entry.new(:source, path: file_path)
      end

      def path_add(relative_path)
        raise "Path (#{relative_path.inspect}) should be a String object" unless relative_path.is_a? String

        file_path = full_file_path relative_path
        raise "Directory does not exist at path #{file_path}" unless @file_system.exist?(file_path)
        raise "#{file_path} is not a directory" unless @file_system.directory?(file_path)

        @shell_entries << Entry.new(:path_add, path: file_path)
      end

      def fpath_add(relative_path)
        raise "Path (#{relative_path.inspect}) should be a String object" unless relative_path.is_a? String

        file_path = full_file_path relative_path
        raise "Directory does not exist at path #{file_path}" unless @file_system.exist?(file_path)
        raise "#{file_path} is not a directory" unless @file_system.directory?(file_path)

        @shell_entries << Entry.new(:fpath_add, path: file_path)
      end

      def env(**environment_vars)
        @shell_env.merge!(environment_vars)
      end
    end
  end
end
