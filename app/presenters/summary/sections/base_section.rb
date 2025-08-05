module Summary
  module Sections
    class BaseSection
      include Routing

      attr_reader :crime_application, :subject

      def initialize(crime_application, editable: true, headless: false, subject: nil)
        @crime_application = crime_application
        @subject = subject
        @editable = editable
        @headless = headless
      end

      # Used by Rails to determine which partial to render.
      # May be overridden in subclasses.
      def to_partial_path
        if list?
          'steps/submission/shared/list_section'
        else
          'steps/submission/shared/section'
        end
      end

      def name
        self.class.name.split('::').last.underscore.to_sym
      end

      # May be overridden in subclasses.
      def heading
        nil
      end

      def title
        I18n.t(
          name,
          scope: 'summary.sections',
          subject: I18n.t("summary.dictionary.subjects.#{subject_type}"),
          ownership: I18n.t("summary.dictionary.ownership.#{subject_type}"),
          count: subject_type.to_s == SubjectType::APPLICANT_AND_PARTNER.to_s ? 2 : 1
        )
      end

      # May be overridden in subclasses to hide/show if appropriate
      def show?
        answers.any?
      end

      def change_path
        # Can be overridden in subclass
        # The path set here will be used as a global change link for the rendered summary card
        nil
      end

      # If action links are allowed (i.e. `change` links)
      def editable?
        crime_application.in_progress? && @editable
      end

      # May be overridden in subclasses if section is a list
      def list?
        false
      end

      # If this section shows the header or not
      def headless?
        @headless
      end

      # Used by the `Routing` module to build the `change` urls
      def default_url_options
        super.merge(id: crime_application)
      end

      private

      delegate :requires_means_assessment?, :kase, :income, :outgoings, :capital, to: :crime_application

      def subject_type
        SubjectType.new(:applicant)
      end

      # :nocov:
      def answers
        raise 'must be implemented in subclasses'
      end
      # :nocov:
    end
  end
end
