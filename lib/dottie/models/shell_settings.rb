# frozen_string_literal: true

module Dottie
  module Models
    class ShellSettings
      attr_reader :commands, :environment_vars

      def initialize(commands = [], environment_vars = {})
        @commands = commands
        @environment_vars = environment_vars
      end

      def merge!(other)
        @commands += other.commands
        @environment_vars.merge!(other.environment_vars)
      end

      def merge(other)
        self.class.new(@commands + other.commands, @environment_vars.merge(other.environment_vars))
      end

      def ==(other)
        @commands == other.commands && @environment_vars == other.environment_vars
      end
    end
  end
end
