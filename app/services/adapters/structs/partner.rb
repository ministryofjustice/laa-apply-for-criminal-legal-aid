module Adapters
  module Structs
    class Partner < BaseStructAdapter
      include PersonIncomePaymentTypes

      def home_address
        HomeAddress.new(super.attributes) if super
      end

      def has_nino
        nino.present? ? 'yes' : 'no'
      end

      def serializable_hash(options = {})
        super(
          options.merge(
            methods: [:has_nino],
          )
        )
      end
    end
  end
end
