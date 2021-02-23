# frozen_string_literal: true

require 'dottie/generator/shell_context'
require 'dottie/models/shell_settings'
require 'dottie/file_system'
require 'dottie/storage'
require 'dottie/template'

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
        context = Dottie::Generator::ShellContext.new(shell_settings)
        output = Dottie::Template.new(@file_system).render(shell_template_path, context)
        save(shell_type, output)
      end

      private

      def shell_template_path
        File.expand_path(File.join('..', 'generator', 'shell.erb'), File.dirname(__FILE__))
      end

      def save(shell_type, content)
        path = File.join(@config.dotfile_path, 'shells', "#{shell_type}.sh")
        @file_system.write_file(path, content)
      end
    end
  end
end
