module Adapters
  module Structs
    class Dependant < BaseStructAdapter
      def serializable_hash(options = {})
        super(
          options.merge(
            methods: [],
            except: []
          )
        )
      end
    end
  end
end
