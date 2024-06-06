module Steps
  module OwnershipConfirmation
    extend ActiveSupport::Concern

    included do
      attr_accessor :confirm_in_applicants_name

      attribute :ownership_type, :value_object, source: OwnershipType

      validates :ownership_type, inclusion: { in: OwnershipType.values, if: :include_partner_in_means_assessment? }
      validate :owned_by_applicant, unless: :include_partner_in_means_assessment?
    end

    def owned_by_applicant
      return unless ownership_type.blank? || !ownership_type.applicant?

      errors.add(:confirm_in_applicants_name, :confirm)
    end

    private

    def set_ownership
      return if include_partner_in_means_assessment?

      self.ownership_type = confirm_in_applicants_name.blank? ? nil : OwnershipType::APPLICANT
    end
  end
end
