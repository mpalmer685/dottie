# frozen_string_literal: true

module Dottie
  class OS
    def self.current
      case RUBY_PLATFORM
      when /cygwin|mswin|mingw|bccwin|wince|emx/
        new :windows
      when /darwin/
        new :macos
      when /linux/
        new :linux
      else
        raise Exception "Unknown platform #{RUBY_PLATFORM}"
      end
    end

    def initialize(os)
      @os = os
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
      case @os
      when :windows
        windows_config_dir
      when :linux
        linux_config_dir
      when :macos
        File.join ENV['HOME'], 'Library', 'Application Support', 'dottie'
      else
        File.join ENV['Home'], '.config', 'dottie'
      end
    end

    private

    def windows_config_dir
      if ENV['LOCALAPPDATA']
        File.join ENV['LOCALAPPDATA'], 'dottie'
      else
        File.join ENV['USERPROFILE'], 'Local Settings', 'Application Data', 'dottie'
      end
    end

    def linux_config_dir
      if ENV['XDG_CONFIG_HOME']
        File.join ENV['XDG_CONFIG_HOME'], 'dottie'
      else
        File.join ENV['HOME'], '.config', 'dottie'
      end
    end
  end
end
