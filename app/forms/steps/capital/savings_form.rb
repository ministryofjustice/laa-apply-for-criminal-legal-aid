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

      validates :provider_name, :sort_code, :account_number, :account_balance, presence: true
      validates :is_overdrawn, :are_wages_paid_into_account, inclusion: { in: YesNoAnswer.values }
      validates :account_holder, inclusion: { in: OwnershipType.values, if: :include_partner? }
      validate :owned_by_applicant, unless: :include_partner?

      def persist!
        record.update(attributes)
      end

      attr_accessor :confirm_in_applicants_name

      # TODO: use proper partner policy once we have one.
      def include_partner?
        YesNoAnswer.new(crime_application.client_has_partner).yes?
      end

      def owned_by_applicant
        return unless account_holder.blank? || !account_holder.applicant?

        errors.add(:confirm_in_applicants_name, :confirm)
      end

      private

      def before_save
        return if include_partner?

        self.account_holder = if confirm_in_applicants_name.blank?
                                nil
                              else
                                OwnershipType::APPLICANT
                              end
      end
    end
  end
end
