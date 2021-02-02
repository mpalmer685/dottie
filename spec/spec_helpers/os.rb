# frozen_string_literal: true

module SpecHelper
  class OS
    def initialize
      @os = :macos
      @config_dir = '.config'
    end

    def use(os, config_dir)
      @os = os
      @config_dir = config_dir
      self
    end

    def windows?
      @os == :windows
    end

    def macos?
      @os == :macos
    end

    def linux?
      @os == :linux
    end

    def config_dir
      File.join @config_dir, 'dottie'
    end
  end
end
