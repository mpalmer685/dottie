# frozen_string_literal: true

require 'tty-logger'

module Dottie
  class Logger < TTY::Logger
    def self.default
      new do |config|
        config.handlers = [:console]
      end
    end

    def self.silent
      new do |config|
        config.handlers = [:null]
      end
    end
  end
end
