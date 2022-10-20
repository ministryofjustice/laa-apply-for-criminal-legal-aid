module Summary
  module Sections
    class Offences < Sections::BaseSection
      def name
        :offences
      end

      def show?
        crime_application.case.present? && super
      end

      def answers
        charges.map.with_index(1) do |charge, index|
          Components::OffenceAnswer.new(
            :offence_details, ChargePresenter.new(charge),
            change_path: edit_steps_case_charges_path(charge),
            i18n_opts: { index: }
          )
        end.select(&:show?)
      end

      private

      def charges
        @charges ||= crime_application.case.charges
      end
    end
  end
end
