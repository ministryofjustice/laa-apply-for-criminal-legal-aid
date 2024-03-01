module Adapters
  module Structs
    class CapitalDetails < BaseStructAdapter
      def savings
        super.map do |attrs|
          Saving.new(**attrs)
        end
      end

      def serializable_hash(options = {})
        super(
          options.merge(
            except: [:savings] # savings belongs to crime_application on Apply
          )
        )
      end
    end
  end
end
