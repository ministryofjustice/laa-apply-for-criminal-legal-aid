module Summary
  module Components
    class Business < BaseRecord
      def business
        record if record.is_a? ApplicationRecord
      end

      private

      def answers # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        [
          Components::FreeTextAnswer.new(
            :trading_name, business.trading_name
          ),
          Components::AddressLineAnswer.new(
            :business_address, business.address
          ),
          Components::FreeTextAnswer.new(
            :nature_of_business, business.description
          ),
          Components::DateAnswer.new(
            :trading_start_date, business.trading_start_date
          ),
          Components::ValueAnswer.new(
            :has_additional_owners, business.has_additional_owners
          ),
          Components::FreeTextAnswer.new(
            :additional_owners, business.additional_owners
          ),
          Components::ValueAnswer.new(
            :has_employees, business.has_employees
          ),
          Components::IntegerAnswer.new(
            :number_of_employees, business.number_of_employees
          ),
          Components::AmountAndFrequencyAnswer.new(
            :turnover, business.turnover
          ),
          Components::AmountAndFrequencyAnswer.new(
            :profit, business.drawings
          ),
          Components::AmountAndFrequencyAnswer.new(
            :drawings, business.profit
          )
        ]
      end

      def name
        I18n.t(business.business_type, scope: [:summary, :sections, :business])
      end

      def change_path
        edit_steps_income_businesses_path(business_id: record.id, subject: subject)
      end

      def summary_path
        edit_steps_income_businesses_summary_path(subject:)
      end

      def remove_path
        confirm_destroy_steps_income_businesses_path(business_id: record.id, subject: subject)
      end

      def subject
        SubjectType.new(business.ownership_type).to_param
      end
    end
  end
end
