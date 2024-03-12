module Summary
  module Sections
    class HousingPayments < Sections::BaseSection
      include ActionView::Helpers::NumberHelper

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
          ] + board_and_lodging_info + council_tax_info
        ).select(&:show?)
      end

      private

      def outgoings
        @outgoings ||= crime_application.outgoings
      end

      def board_and_lodging_info # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        return [] unless board_and_lodging

        details = board_and_lodging.metadata['details']

        [
          Components::FreeTextAnswer.new(
            :board_amount, formatted_amount_and_frequency(details['board_amount'], board_and_lodging.frequency.value),
            change_path: edit_steps_outgoings_board_and_lodging_path
          ),
          Components::FreeTextAnswer.new(
            :food_amount, formatted_amount_and_frequency(details['food_amount'], board_and_lodging.frequency.value),
            change_path: edit_steps_outgoings_board_and_lodging_path
          ),
          Components::FreeTextAnswer.new(
            :payee_name, details['payee_name'],
            change_path: edit_steps_outgoings_board_and_lodging_path
          ),
          Components::FreeTextAnswer.new(
            :payee_relationship_to_client, details['payee_relationship_to_client'],
            change_path: edit_steps_outgoings_board_and_lodging_path
          )
        ]
      end

      def council_tax_info
        return [] if board_and_lodging

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

      def formatted_amount_and_frequency(amount, frequency)
        "#{number_to_currency(amount, unit: '£', separator: '.',
delimiter: ',')} every #{PaymentFrequencyType.to_phrase(frequency)}"
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
