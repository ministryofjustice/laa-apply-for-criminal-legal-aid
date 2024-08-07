module Adapters
  module Structs
    class IncomeDetails < BaseStructAdapter
      include EmployedIncome
      include SelfEmployedIncome
      include PersonIncomePaymentTypes

      def employment_status
        # TODO: Handle this having multiple employment status' when we get designs for employed
        employment_type || []
      end

      def applicant_self_assessment_tax_bill_amount
        Money.new(super)
      end

      def income_payments
        return [] unless __getobj__

        @income_payments ||= super.map { |struct| IncomePayment.new(**struct) }
      end

      def income_benefits
        return [] unless __getobj__

        @income_benefits ||= super.map { |struct| IncomeBenefit.new(**struct) }
      end

      def partner_self_assessment_tax_bill_amount
        Money.new(super)
      end

      def partner_employment_status
        partner_employment_type || []
      end

      def employments
        return [] unless __getobj__

        super.map do |attrs|
          if attrs.respond_to?(:deductions)
            attrs.deductions.map! do |po|
              Deduction.new(po.attributes)
            end
          end
          Employment.new(**attrs)
        end
      end

      def businesses
        return [] unless __getobj__

        @businesses ||= super.map { |struct| Business.new(**struct) }
      end

      def serializable_hash(options = {})
        super(
          options.merge(
            methods: [:employment_status, :partner_employment_status],
            # `employment_type` is the name for employment_status
            # in the datastore, we don't use it
            except: [
              :employment_type, :partner_employment_type,
              :dependants, :income_payments, :income_benefits,
              :employments, :employment_income_payments, :businesses
            ]
          )
        )
      end
    end
  end
end
