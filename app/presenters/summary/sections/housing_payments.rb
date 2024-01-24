module Summary
  module Sections
    class HousingPayments < Sections::BaseSection
      def show?
        outgoings.present? && super
      end

      def answers
        [
          Components::ValueAnswer.new(
            :housing_payment_type, outgoings.housing_payment_type,
            change_path: edit_steps_outgoings_housing_payment_type_path
          ),
        ].select(&:show?)
      end

      private

      def outgoings
        @outgoings ||= crime_application.outgoings
      end
    end
  end
end
