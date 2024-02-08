module Steps
  module Outgoings
    class ClientRentPaymentsForm < Steps::BaseFormObject

      # attribute :rent_payment_amount, :integer
      # attribute :rent_payment_frequency, :value_object, source: Frequencies

      # validates :rent_payment_frequency,
      #           inclusion: { in: :choices }

      # def choices
      #   RentPayment.values
      # end

      # private
      #
      # def persist!
      #   outgoings.update(
      #     attributes
      #   )
      # end
    end
  end
end
