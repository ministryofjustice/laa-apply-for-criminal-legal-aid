module Summary
  module Components
    class Codefendant < BaseRecord
      alias codefendant record

      private

      def answers
        [
          FreeTextAnswer.new(:first_name, codefendant.first_name),
          FreeTextAnswer.new(:last_name, codefendant.last_name),
          ValueAnswer.new(:conflict_of_interest, codefendant.conflict_of_interest)
        ]
      end

      def name
        I18n.t('summary.sections.codefendant')
      end

      def change_path
        edit_steps_case_codefendants_path(
          id: record.case.crime_application_id,
          anchor: "codefendant_#{index}"
        )
      end

      alias summary_path change_path
      alias remove_path change_path
    end
  end
end
