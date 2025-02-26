module Summary
  module Sections
    class Properties < BaseCapitalRecordsSection
      def heading
        :assets
      end

      private

      def has_no_records_component
        Components::ValueAnswer.new(
          :has_assets,
          has_records_answer,
          change_path: edit_steps_capital_property_type_path,
          subject_type: subject_type,
          i18n_opts: i18n_opts
        )
      end

      def item_component_class
        Summary::Components::Property
      end

      def records
        @records ||= capital.properties
      end

      def subject_type
        if crime_application.has_partner?
          SubjectType.new(:applicant_and_partner)
        else
          SubjectType.new(:applicant)
        end
      end

      def i18n_opts
        { count: subject_type.applicant_and_partner? ? 2 : 1 }
      end

      def has_records_answer
        case capital.has_no_properties
        when 'yes'
          'none'
        when 'no'
          YesNoAnswer::YES
        else
          capital.has_no_properties
        end
      end
    end
  end
end
