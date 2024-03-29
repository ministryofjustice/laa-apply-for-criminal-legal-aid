module Adapters
  module Structs
    class IncomeDetails < BaseStructAdapter
      def employment_status
        # TODO: Handle this having multiple employment status' when we get designs for employed
        employment_type || []
      end

      # `client_has_dependants` is not part of Schema, requires calculation
      def client_has_dependants
        dependants&.any? ? YesNoAnswer::YES : YesNoAnswer::NO
      end

      def serializable_hash(options = {})
        super(
          options.merge(
            methods: [:employment_status, :client_has_dependants],
            # `employment_type` is the name for employment_status
            # in the datastore, we don't use it
            except: [:employment_type, :dependants, :income_payments, :income_benefits]
          )
        )
      end
    end
  end
end
