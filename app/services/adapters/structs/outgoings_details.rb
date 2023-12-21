module Adapters
  module Structs
    class OutgoingsDetails < BaseStructAdapter
      def serializable_hash(options = {})
        super(
          options.merge(
            methods: [],
            except: [:outgoings],
          )
        )
      end
    end
  end
end
