# frozen_string_literal: true

require 'tty-logger'

require 'dottie/logger/handler'

module Dottie
  class Logger
    def self.default
      @@default ||= new(Handler)
    end

    def self.silent
      @@silent ||= new(:null)
    end

    def initialize(handler)
      @logger = TTY::Logger.new do |config|
        config.handlers = [handler]
      end
      @indentation_level = 0
    end

    def self.define_level(name)
      define_method(name) do |*msg, &block|
        begin
          @logger.send(name, *msg, indentation_level: @indentation_level)

          @indentation_level += 2
          block&.call
        ensure
          @indentation_level -= 2
        end
      end
    end

    define_level :debug
    define_level :info
    define_level :warn
    define_level :error
    define_level :fatal
    define_level :success
    define_level :wait
  end
end
