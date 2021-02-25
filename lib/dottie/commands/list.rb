# frozen_string_literal: true

require 'pastel'

require 'dottie/storage'

module Dottie
  module Commands
    class List
      def initialize(model_storage = Dottie::Storage.new)
        @config = model_storage.config
        @pastel = Pastel.new
      end

      def run
        profiles = @config.all_profiles
        if profiles.empty?
          puts <<~INSTALL
            No profiles installed. You can install a profile by running

              #{@pastel.cyan.bold('dottie install PROFILE_LOCATION')}
          INSTALL
          return
        end

        puts ''
        puts @pastel.bold('Installed profiles:')
        puts format_profiles(profiles)
      end

      private

      def format_profiles(profiles)
        max_profile_name_length = profiles.map { |p| p.name.length }.max
        profiles
          .map { |p| format_profile(p, max_profile_name_length) }
          .join('\n')
      end

      def format_profile(profile, name_column_width)
        [
          ' ',
          @pastel.cyan.bold(profile.name.ljust(name_column_width)),
          @pastel.dim.white("(#{@config.profile_description(profile)})")
        ].join(' ')
      end
    end
  end
end
