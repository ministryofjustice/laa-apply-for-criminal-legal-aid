module Steps
  module Ownable
    extend ActiveSupport::Concern
    
    included do
      validates :ownership_type, inclusion: { in: OwnershipType.values, if: :include_partner? }
      validate :owned_by_applicant, unless: :include_partner?

      attr_accessor :confirm_in_applicants_name

      def include_partner?
        YesNoAnswer.new(crime_application.client_has_partner.to_s).yes?
      end

      def owned_by_applicant
        return unless ownership_type.blank? || !ownership_type.applicant?

        errors.add(:confirm_in_applicants_name, :confirm)
      end

      private

      def before_save
        set_ownership
      end

      def set_ownership
        return if include_partner?

        self.ownership_type = if confirm_in_applicants_name.blank?
                                nil
                              else
                                OwnershipType::APPLICANT
                              end
      end
    end
  end
end
