module Adapters
  module Structs
    class IncomeDetails < BaseStructAdapter
      def employment_status
        # TODO: Handle this having multiple employment status' when we get designs for employed
        employment_type || []
      end

      def applicant_self_assessment_tax_bill_amount
        Money.new(super)
      end

      def partner_employment_status
        partner_employment_type || []
      end

      # TODO: Need to update schema fixtures to improve the coverage
      # :nocov:
      def employments
        return [] unless __getobj__

        super.map do |attrs|
          if attrs.respond_to?(:deductions)
            attrs.deductions.map! do |po|
              Deduction.new(**po)
            end
          end
          Employment.new(**attrs)
        end
      end

      def partner_employments
        return [] unless __getobj__

        super.map do |attrs|
          if attrs.respond_to?(:deductions)
            attrs.deductions.map! do |po|
              Deduction.new(**po)
            end
          end
          Employment.new(**attrs)
        end
      end
      # :nocov:

      def serializable_hash(options = {})
        super(
          options.merge(
            methods: [:employment_status, :partner_employment_status],
            # `employment_type` is the name for employment_status
            # in the datastore, we don't use it
            except: [
              :employment_type, :partner_employment_type,
              :dependants, :income_payments, :income_benefits,
              :employments, :partner_employments
            ]
          )
        )
      end
    end
  end
end
