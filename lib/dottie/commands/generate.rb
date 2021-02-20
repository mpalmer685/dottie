# frozen_string_literal: true

require 'dottie/models/shell_settings'
require 'dottie/file_system'
require 'dottie/generator'
require 'dottie/storage'

module Dottie
  module Commands
    class Generate
      def initialize(model_storage = Dottie::Storage.new, file_system = Dottie::FileSystem.new)
        @model_storage = model_storage
        @file_system = file_system

        @config = @model_storage.config
      end

      def run(shell_type)
        shell_settings = @config.shell_settings(:common).merge(@config.shell_settings(shell_type))
        output = Dottie::Generator.generate(shell_settings)
        save(shell_type, output)
      end

      private

      def save(shell_type, content)
        path = File.join(@config.dotfile_path, 'shells', "#{shell_type}.sh")
        @file_system.write_file(path, content)
      end
    end
  end
end
