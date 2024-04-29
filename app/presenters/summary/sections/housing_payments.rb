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
          ] + board_and_lodging_info + council_tax_info
        ).select(&:show?)
      end

      private

      def board_and_lodging_info # rubocop:disable Metrics/MethodLength
        return [] unless board_and_lodging

        [
          Components::PaymentAnswer.new(
            :board_amount, board_and_lodging_board_amount,
            change_path: edit_steps_outgoings_board_and_lodging_path
          ),
          Components::PaymentAnswer.new(
            :food_amount, board_and_lodging_food_amount,
            change_path: edit_steps_outgoings_board_and_lodging_path
          ),
          Components::FreeTextAnswer.new(
            :payee_name, board_and_lodging.payee_name,
            change_path: edit_steps_outgoings_board_and_lodging_path
          ),
          Components::FreeTextAnswer.new(
            :payee_relationship_to_client, board_and_lodging.payee_relationship_to_client,
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

      def board_and_lodging_board_amount
        OutgoingsPayment.new(
          amount: board_and_lodging.board_amount,
          frequency: PaymentFrequencyType.new(board_and_lodging.frequency),
        )
      end

      def board_and_lodging_food_amount
        OutgoingsPayment.new(
          amount: board_and_lodging.food_amount,
          frequency: PaymentFrequencyType.new(board_and_lodging.frequency),
        )
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
