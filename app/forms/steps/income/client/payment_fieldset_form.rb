module Steps
  module Income
    module Client
      class PaymentFieldsetForm < Steps::BaseFormObject
        attribute :_destroy, :boolean
        attribute :id, :string
        attribute :amount
        attribute :frequency

        attribute :type
        attribute :payment_type
        attribute :crime_application_id

        validates :amount, :frequency, presence: true

        def persist!
          id.present?
        end
      end
    end
  end
end
