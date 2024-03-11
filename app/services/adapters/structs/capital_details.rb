module Adapters
  module Structs
    class CapitalDetails < BaseStructAdapter
      def savings
        return [] unless __getobj__

        super.map { |attrs| Saving.new(**attrs) }
      end

      def serializable_hash(options = {})
        super options.merge(except: [:savings, :investments])
      end
    end
  end
end
