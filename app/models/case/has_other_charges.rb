module Case::HasOtherCharges # rubocop:disable Style/ClassAndModuleChildren
  extend ActiveSupport::Concern

  delegate :partner, :partner_detail, to: :crime_application

  included do
    has_one(:client_other_charge,
            -> { where(ownership_type: OwnershipType::APPLICANT.to_s) },
            inverse_of: :case,
            class_name: 'OtherCharge',
            dependent: :destroy)

    has_one(:partner_other_charge,
            -> { where(ownership_type: OwnershipType::PARTNER.to_s) },
            inverse_of: :case,
            class_name: 'OtherCharge',
            dependent: :destroy)
  end

  def client_other_charge_in_progress
    return unless require_client_other_charge_in_progress?

    super
  end

  def partner_other_charge_in_progress
    return unless require_partner_other_charge_in_progress?

    super
  end

  def client_other_charge
    return unless require_client_other_charge?

    super
  end

  def partner_other_charge
    return unless require_partner_other_charge?

    super
  end

  def require_client_other_charge_in_progress?
    !crime_application.non_means_tested? && case_eligible_for_other_charge?
  end

  def require_client_other_charge?
    require_client_other_charge_in_progress? && client_other_charge_in_progress == YesNoAnswer::YES.to_s
  end

  def require_partner_other_charge_in_progress?
    !crime_application.non_means_tested? && case_eligible_for_other_charge? && partner_relevant_for_other_charge?
  end

  def require_partner_other_charge?
    require_partner_other_charge_in_progress? && partner_other_charge_in_progress == YesNoAnswer::YES.to_s
  end

  private

  def case_eligible_for_other_charge?
    return false if case_type.blank?

    CaseType.new(case_type).in?([CaseType::EITHER_WAY, CaseType::INDICTABLE, CaseType::ALREADY_IN_CROWN_COURT])
  end

  def partner_relevant_for_other_charge?
    return false unless partner.present? && partner_detail.present?

    partner_detail.involvement_in_case != PartnerInvolvementType::NONE.to_s &&
      partner_detail.conflict_of_interest == YesNoAnswer::NO.to_s
  end
end
