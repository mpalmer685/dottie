# frozen_string_literal: true

require 'dottie/file_system'
require 'dottie/os'
require 'dottie/resetter'

module Dottie
  module Commands
    module Reset
      module_function

      def run
        puts 'Removing dottie files and settings'
        Dottie::Resetter.new(Dottie::FileSystem, Dottie::OS.current).reset
      rescue RuntimeError => e
        warn e.message
        exit 1
      end
    end
  end
end
