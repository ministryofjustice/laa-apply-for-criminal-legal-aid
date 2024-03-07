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
          Components::PaymentAnswer.new(
            :mortgage, mortgage,
            change_path: edit_steps_outgoings_mortgage_path
          ),
        ].select(&:show?)
      end

      private

      def outgoings
        @outgoings ||= crime_application.outgoings
      end

      # TODO: Attempted to get an appropriate Struct to return this value
      # however doing so caused headache with specs
      def mortgage
        crime_application.outgoings_payments.find do |p|
          p.payment_type == HousingPaymentType::MORTGAGE.to_s
        end
      end
    end
  end
end
