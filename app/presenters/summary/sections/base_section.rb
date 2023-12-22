module Summary
  module Sections
    class BaseSection
      include Routing

      attr_reader :crime_application

      def initialize(crime_application, editable: true, headless: false)
        @crime_application = crime_application
        @editable = editable
        @headless = headless
      end

      # Used by Rails to determine which partial to render.
      # May be overridden in subclasses.
      def to_partial_path
        'steps/submission/shared/section'
      end

      def name
        self.class.name.split('::').last.underscore.to_sym
      end

      # May be overridden in subclasses to hide/show if appropriate
      def show?
        answers.any?
      end

      # If action links are allowed (i.e. `change` links)
      def editable?
        crime_application.in_progress? && @editable
      end

      # If this section shows the header or not
      def headless?
        @headless
      end

      # Used by the `Routing` module to build the `change` urls
      def default_url_options
        { id: crime_application }
      end

      private

      # :nocov:
      def answers
        raise 'must be implemented in subclasses'
      end
      # :nocov:
    end
  end
end
