module Summary
  module Sections
    class Codefendants < Sections::BaseSection
      def show?
        kase.present? && super
      end

      # rubocop:disable Metrics/MethodLength
      def answers
        [
          Components::ValueAnswer.new(
            :has_codefendants, kase.has_codefendants,
            change_path: edit_steps_case_has_codefendants_path
          ),

          codefendants.map.with_index(1) do |codefendant, index|
            Components::FreeTextAnswer.new(
              :codefendant_full_name, name_and_conflict(codefendant),
              change_path: edit_steps_case_codefendants_path(anchor: "codefendant_#{index}"),
              i18n_opts: { index: }
            )
          end
        ].flatten.select(&:show?)
      end
      # rubocop:enable Metrics/MethodLength

      private

      def kase
        @kase ||= crime_application.case
      end

      def codefendants
        @codefendants ||= kase.codefendants
      end

      def name_and_conflict(codefendant)
        [codefendant.full_name,
         I18n.t("#{codefendant.conflict_of_interest}_html", scope: 'summary.questions.conflict_of_interest')].join
      end
    end
  end
end
