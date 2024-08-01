module Adapters
  module Structs
    class OutgoingsDetails < BaseStructAdapter
      include TypesOfOutgoings

      def outgoings_payments
        return [] unless __getobj__

        @outgoings_payments ||= outgoings.map { |struct| OutgoingsPayment.new(**struct) }
      end

      def serializable_hash(options = {})
        super(
          options.merge(
            methods: [],
            except: [:outgoings]
          )
        )
      end
    end
  end
end
