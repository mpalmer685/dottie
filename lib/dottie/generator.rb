# frozen_string_literal: true

require 'dottie/generator/shell_context'
require 'dottie/generator/shell_template'

module Dottie
  module Generator
    module_function

    def generate(shell_settings)
      ShellTemplate.template.result(ShellContext.new(shell_settings).get_binding)
    end
  end
end
