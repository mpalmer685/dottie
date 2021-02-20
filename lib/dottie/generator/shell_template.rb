# frozen_string_literal: true

require 'erb'

module Dottie
  module Generator
    module ShellTemplate
      module_function

      def template
        if RUBY_VERSION < '2.6'
          ERB.new(File.read(File.join(File.dirname(__FILE__), 'shell.erb')), nil, '-')
        else
          ERB.new(File.read(File.join(File.dirname(__FILE__), 'shell.erb')), trim_mode: '-')
        end
      end
    end
  end
end
