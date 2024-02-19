module Steps
  module Capital
    class SavingsForm < Steps::BaseFormObject
      delegate :saving_type, to: :record

      attribute :provider_name, :string
      attribute :account_balance, :pence
      attribute :sort_code, :string
      attribute :account_number, :string
      attribute :is_overdrawn, :value_object, source: YesNoAnswer
      attribute :are_wages_paid_into_account, :value_object, source: YesNoAnswer
      attribute :account_holder, :value_object, source: OwnershipType

      validates_presence_of(
        :provider_name,
        :sort_code,
        :account_number,
        :account_balance
      )

      validates_inclusion_of(
        :is_overdrawn,
        :are_wages_paid_into_account,
        in: YesNoAnswer.values
      )
      
      validates :account_holder, inclusion: { in: OwnershipType.values, if: :include_partner? }

      validate :owned_by_applicant, unless: :include_partner?

      def persist!
        record.update(attributes)
      end

      def confirm_in_applicants_name=(confirm)
        self.account_holder = OwnershipType::APPLICANT if confirm
      end
      
      def confirm_in_applicants_name
        account_holder == OwnershipType::APPLICANT
      end
      
      # TODO: use proper partner policy once we have one.
      def include_partner?
        YesNoAnswer.new(crime_application.client_has_partner).yes?
      end

      def owned_by_applicant
        if account_holder.blank? || !account_holder.applicant?
          errors.add(:confirm_in_applicants_name, :confirm) 
        end
      end
    end
  end
end
