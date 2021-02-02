# frozen_string_literal: true

require 'dottie/file_system'
require 'dottie/initializer'
require 'dottie/os'

module Dottie
  module Commands
    module Init
      module_function

      def run(dotfile_path_arg)
        dotfile_path = File.expand_path dotfile_path_arg

        begin
          puts "Setting up dottie at #{dotfile_path}"
          Dottie::Initializer.new(Dottie::FileSystem, Dottie::OS.current).init dotfile_path
        rescue RuntimeError => e
          warn e.message
          exit 1
        end
      end
    end
  end
end
