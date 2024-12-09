module Summary
  module Components
    class Business < BaseRecord
      include HasDynamicSubject

      GROUP_BY = :business_type

      alias business record

      private

      def answers # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        [
          Components::FreeTextAnswer.new(
            :trading_name, business.trading_name, show: true
          ),
          Components::AddressLineAnswer.new(
            :business_address, business.address, show: true
          ),
          Components::FreeTextAnswer.new(
            :nature_of_business, business.description, show: true
          ),
          Components::DateAnswer.new(
            :trading_start_date, business.trading_start_date, show: true
          ),
          Components::ValueAnswer.new(
            :has_additional_owners, business.has_additional_owners, show: true
          ),
          Components::FreeTextAnswer.new(
            :additional_owners, business.additional_owners,
            show: business.has_additional_owners == 'yes'
          ),
          Components::ValueAnswer.new(
            :has_employees, business.has_employees, show: true
          ),
          Components::FreeTextAnswer.new(
            :number_of_employees, business.number_of_employees.to_s,
            show: business.has_employees == 'yes'
          ),
          Components::AmountAndFrequencyAnswer.new(
            :turnover, business.turnover, show: true
          ),
          Components::AmountAndFrequencyAnswer.new(
            :drawings, business.drawings, show: true
          ),
          Components::AmountAndFrequencyAnswer.new(
            :profit, business.profit, show: true
          ),
          Components::AmountAndFrequencyAnswer.new(
            :salary, business.salary, show: business.salary&.amount.present?
          ),
          Components::AmountAndFrequencyAnswer.new(
            :total_income_share_sales, business.total_income_share_sales,
            show: business.total_income_share_sales&.amount.present?
          ),
          Components::PercentageAnswer.new(
            :percentage_profit_share,
            business.percentage_profit_share,
            show: business.percentage_profit_share.present?
          ),
        ].select(&:show?)
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

      alias subject_type subject
    end
  end
end
