# frozen_string_literal: true

require 'erb'

module Dottie
  class Template
    class Context
      def get_binding
        binding
      end
    end

    def initialize(file_system = Dottie::FileSystem.new)
      @file_system = file_system
    end

    def render(template_path, context)
      template(template_path).result(context.get_binding)
    end

    private

    def template(template_path)
      template_file = @file_system.read_file(template_path)
      if RUBY_VERSION < '2.6'
        ERB.new(template_file, nil, '-')
      else
        ERB.new(template_file, trim_mode: '-')
      end
    end
  end
end
