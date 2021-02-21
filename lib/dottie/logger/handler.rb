# frozen_string_literal: true

require 'pastel'
require 'tty-logger'

module Dottie
  class Logger
    class Handler
      include TTY::Logger::Handlers::Base

      STYLES = {
        debug: {
          symbol: '•',
          color: :cyan
        },
        info: {
          symbol: 'ℹ',
          color: :cyan
        },
        warn: {
          symbol: '⚠',
          color: :yellow
        },
        error: {
          symbol: '⨯',
          color: :red
        },
        fatal: {
          symbol: '!',
          color: :red
        },
        success: {
          symbol: '✔',
          color: :green
        },
        wait: {
          symbol: '…',
          color: :cyan
        }
      }.freeze

      def initialize(**opts)
        @output = Array[opts.fetch(:output, $stderr)].flatten
        @mutex = Mutex.new
        @pastel = Pastel.new(enabled: opts.fetch(:enable_color, nil))
      end

      def call(event)
        @mutex.lock

        style = configure_styles(event)
        color = configure_color(style)
        indentation_level = event.fields.fetch(:indentation_level, 0)

        fmt = []
        fmt << indent(color.call(style[:symbol]), indentation_level) unless style.empty?
        fmt << event.message.join(' ')
        fmt << "\n" + format_backtrace(event) unless event.backtrace.empty?

        @output.each { |out| out.puts fmt.join(' ') }
      ensure
        @mutex.unlock
      end

      private

      def indent(message, indentation_level)
        (' ' * indentation_level) + message
      end

      def format_backtrace(event)
        event.backtrace.map do |bktrace|
          indent(bktrace.to_s, 4)
        end.join("\n")
      end

      def configure_styles(event)
        return {} if event.metadata[:name].nil?

        STYLES.fetch(event.metadata[:name].to_sym, {})
      end

      def configure_color(style)
        color = style.fetch(:color) { :cyan }
        @pastel.send(color).detach
      end
    end
  end
end
