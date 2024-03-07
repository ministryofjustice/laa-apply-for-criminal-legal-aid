module Summary
  module Sections
    class HousingPayments < Sections::BaseSection
      def show?
        outgoings.present? && super
      end

      def answers # rubocop:disable Metrics/MethodLength
        (
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
          ] + council_tax_info
        ).select(&:show?)
      end

      private

      def outgoings
        @outgoings ||= crime_application.outgoings
      end

      def council_tax_info
        return [] if board_lodgings

        [
          Components::ValueAnswer.new(
            :pays_council_tax, outgoings.pays_council_tax,
            change_path: edit_steps_outgoings_council_tax_path
          ),
          Components::PaymentAnswer.new(
            :council_tax, council_tax,
            change_path: edit_steps_outgoings_council_tax_path
          ),
        ]
      end

      # TODO: Attempted to get an appropriate Struct to return this value
      # however doing so caused headache with specs. Ensure match is using
      # .to_s to ensure both ActiveRecord and Struct models work as expected
      (HousingPaymentType::VALUES + [OutgoingsPaymentType::COUNCIL_TAX]).each do |type|
        define_method(type.to_s) do
          crime_application.outgoings_payments.find do |p|
            p.payment_type.to_s == type.to_s
          end
        end
      end
    end
  end
end
