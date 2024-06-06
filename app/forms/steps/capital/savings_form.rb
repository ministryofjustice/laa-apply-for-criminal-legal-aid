module Steps
  module Capital
    class SavingsForm < Steps::BaseFormObject
      include TypeOfMeansAssessment
      include OwnershipConfirmation
      include ApplicantOrPartner

      delegate :saving_type, to: :record

      attribute :provider_name, :string
      attribute :account_balance, :pence
      attribute :sort_code, :string
      attribute :account_number, :string
      attribute :is_overdrawn, :value_object, source: YesNoAnswer
      attribute :are_wages_paid_into_account, :value_object, source: YesNoAnswer
      attribute :are_partners_wages_paid_into_account, :value_object, source: YesNoAnswer

      validates :provider_name, :sort_code, :account_number, :account_balance, presence: true
      validates :is_overdrawn, :are_wages_paid_into_account, inclusion: { in: YesNoAnswer.values }

      validates(
        :are_partners_wages_paid_into_account,
        inclusion: { in: YesNoAnswer.values, if: :include_partner_in_means_assessment? }
      )

      def persist!
        record.update(attributes)
      end

      private

      def before_save
        set_ownership
      end
    end
  end
end
