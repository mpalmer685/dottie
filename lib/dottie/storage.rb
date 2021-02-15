# frozen_string_literal: true

module Dottie
  class Storage
    attr_writer :config, :exec_cache

    def initialize(file_system = Dottie::FileSystem, os = Dottie::OS.current)
      @file_system = file_system
      @os = os
    end

    def config
      @config ||= load_model(Dottie::Models::Config)
    end

    def exec_cache
      @exec_cache ||= load_model(Dottie::Models::ExecCache)
    end

    def load_model(model_class)
      model_class.load_yaml(@file_system, @os)
    end

    def save_model(model)
      model.save(@file_system, @os)
    end
  end
end
