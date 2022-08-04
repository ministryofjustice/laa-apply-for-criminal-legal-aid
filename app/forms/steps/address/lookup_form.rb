module Steps
  module Address
    class LookupForm < Steps::BaseFormObject
      attribute :postcode, :string
      validates :postcode, presence: true

      private

      def persist!
        record.update(
          attributes
        )
      end
    end
  end
end
