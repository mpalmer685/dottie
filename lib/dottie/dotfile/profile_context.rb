# frozen_string_literal: true

require 'dottie/template'

module Dottie
  class Dotfile
    class ProfileContext < Dottie::Template::Context
      def initialize(profile)
        @profile = profile
      end

      def profile_location
        @profile.location
      end
    end
  end
end
