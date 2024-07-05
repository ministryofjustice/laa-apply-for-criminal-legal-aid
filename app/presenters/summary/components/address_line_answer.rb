module Summary
  module Components
    class AddressLineAnswer < BaseAnswer
      def answer_text
        return nil unless value

        address.values_at(*Address::ADDRESS_ATTRIBUTES).compact_blank.join(', ')
      end

      private

      def address
        ActiveSupport::HashWithIndifferentAccess.new(value)
      end
    end
  end
end
