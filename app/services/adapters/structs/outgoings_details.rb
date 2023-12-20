module Adapters
  module Structs
    class OutgoingsDetails < BaseStructAdapter
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
