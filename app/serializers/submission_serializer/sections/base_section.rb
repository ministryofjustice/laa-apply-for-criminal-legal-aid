require 'jbuilder'

module SubmissionSerializer
  module Sections
    class BaseSection
      include TypeOfApplication
      include TypeOfMeansAssessment

      attr_reader :crime_application

      def initialize(crime_application)
        @crime_application = crime_application
      end

      def generate
        to_builder.attributes!
      end

      def generate?
        current_version >= min_version
      end

      # May be overridden in subclasses if required
      def min_version
        1.0
      end

      # TODO: this in theory will come from a DB attribute
      # :nocov:
      def current_version
        1.0
      end
      # :nocov:

      # :nocov:
      def to_builder
        raise 'must be implemented in subclasses'
      end
      # :nocov:
    end
  end
end
