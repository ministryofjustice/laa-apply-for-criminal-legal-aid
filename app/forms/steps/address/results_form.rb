module Steps
  module Address
    class ResultsForm < BaseFormObject
      attribute :lookup_id, :string
      validates :lookup_id, inclusion: {
        in: ->(this) { this.addresses.pluck(:lookup_id) }
      }

      def addresses
        @addresses ||= retrieve_addresses
      end

      private

      def retrieve_addresses
        @addresses = lookup_service.call

        # Add the number of results as the first element of the collection
        # User has to select something, otherwise there is a validation error
        addresses.unshift(address_count_item) if addresses.any?

        addresses
      end

      def address_count_item
        Struct.new(:results_size, :lookup_id) do
          def address_lines
            I18n.translate!(:results_count, count: results_size, scope: 'steps.address.results.edit')
          end
        end.new(addresses.size)
      end

      def lookup_service
        @lookup_service ||= Ordnance::AddressLookup.new(
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
