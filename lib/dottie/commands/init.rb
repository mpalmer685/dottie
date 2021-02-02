# frozen_string_literal: true

module Dottie
  module Commands
    module Init
      module_function

      def run(dotfile_path_arg)
        dotfile_path = File.expand_path dotfile_path_arg

        begin
          puts "Setting up dottie at #{dotfile_path}"
        end
      end
    end
  end
end
