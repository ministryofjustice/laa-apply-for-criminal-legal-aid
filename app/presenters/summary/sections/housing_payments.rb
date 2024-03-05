module Summary
  module Sections
    class HousingPayments < Sections::BaseSection
      def show?
        outgoings.present? && super
      end

      def answers # rubocop:disable Metrics/MethodLength
        [
          Components::ValueAnswer.new(
            :housing_payment_type, outgoings.housing_payment_type,
            change_path: edit_steps_outgoings_housing_payment_type_path
          ),
          Components::PaymentAnswer.new(
            :mortgage, mortgage,
            change_path: edit_steps_outgoings_mortgage_path
          ),
          Components::PaymentAnswer.new(
            :rent, rent,
            change_path: edit_steps_outgoings_rent_path
          ),
        ].select(&:show?)
      end

      private

      def outgoings
        @outgoings ||= crime_application.outgoings
      end

      # TODO: Attempted to get an appropriate Struct to return this value
      # however doing so caused headache with specs. Ensure match is using
      # .to_s to ensure both ActiveRecord and Struct models work as expected
      def mortgage
        crime_application.outgoings_payments.find do |p|
          p.payment_type.to_s == HousingPaymentType::MORTGAGE.to_s
        end
      end

      def rent
        crime_application.outgoings_payments.find do |p|
          p.payment_type.to_s == HousingPaymentType::RENT.to_s
        end
      end
    end
  end
end
