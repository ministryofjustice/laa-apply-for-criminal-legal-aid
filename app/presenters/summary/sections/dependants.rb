module Summary
  module Sections
    class Dependants < Sections::BaseSection
      def show?
        income.present? && super
      end

      # rubocop:disable Metrics/MethodLength
      def answers
        [
          Components::ValueAnswer.new(
            :client_has_dependants, income.client_has_dependants,
            change_path: edit_steps_income_client_has_dependants_path
          ),

          dependants.map.with_index(1) do |dependant, index|
            Components::FreeTextAnswer.new(
              :dependant, age(dependant),
              change_path: edit_steps_income_dependants_path,
              i18n_opts: { ordinal: index }
            )
          end
        ].flatten.select(&:show?)
      end
      # rubocop:enable Metrics/MethodLength

      private

      def age(dependant)
        I18n.t('summary.questions.dependant.answers.age', age: dependant.age, count: dependant.age)
      end

      def dependants
        @dependants ||= crime_application.dependants
      end
    end
  end
end
