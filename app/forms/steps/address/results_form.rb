module Steps
  module Address
    class ResultsForm < BaseFormObject
      attribute :lookup_id, :string
      validates :lookup_id, inclusion: { in: :address_ids }

      def addresses
        @addresses ||= lookup_service.call
      end

      def address_ids
        addresses.pluck(:lookup_id)
      end

      private

      def lookup_service
        @lookup_service ||= OrdnanceSurvey::AddressLookup.new(
          record.postcode
        )
      end

      def selected_address
        addresses.detect { |address| address.lookup_id == lookup_id }
      end

      def persist!
        record.update(
          selected_address.to_h
        )
      end
    end
  end
end
