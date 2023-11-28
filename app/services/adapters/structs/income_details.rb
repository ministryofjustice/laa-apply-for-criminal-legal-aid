module Adapters
  module Structs
    class IncomeDetails < BaseStructAdapter
      def serializable_hash(options = {})
        super(
          options.merge(
            methods: []
          )
        )
      end
    end
  end
end
