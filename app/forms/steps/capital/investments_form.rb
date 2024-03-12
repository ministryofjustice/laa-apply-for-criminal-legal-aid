module Steps
  module Capital
    class InvestmentsForm < Steps::BaseFormObject
      delegate :investment_type, to: :record

      attribute :description, :string
      attribute :value, :pence
      attribute :holder, :value_object, source: OwnershipType

      validates :description, :value, presence: true
      validates :holder, inclusion: { in: OwnershipType.values, if: :include_partner? }
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
        return unless holder.blank? || !holder.applicant?

        errors.add(:confirm_in_applicants_name, :confirm)
      end

      private

      def before_save
        return if include_partner?

        self.holder = if confirm_in_applicants_name.blank?
                        nil
                      else
                        OwnershipType::APPLICANT
                      end
      end
    end
  end
end
