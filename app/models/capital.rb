class Capital < ApplicationRecord
  include MeansOwnershipScope

  belongs_to :crime_application

  attribute :premium_bonds_total_value, :pence
  attribute :partner_premium_bonds_total_value, :pence
  attribute :trust_fund_amount_held, :pence
  attribute :trust_fund_yearly_dividend, :pence
  attribute :partner_trust_fund_amount_held, :pence
  attribute :partner_trust_fund_yearly_dividend, :pence

  validate on: :submission do
    answers_validator.validate
    confirmation_validator.validate
  end

  validate on: :check_answers do
    answers_validator.validate
  end

  def complete?
    valid?(:submission)
  end

  def savings
    return [] unless requires_full_capital?

    crime_application.savings.where(ownership_type: ownership_types)
  end

  def properties
    return [] unless requires_full_capital?

    crime_application.properties
  end

  def investments
    return [] unless requires_full_capital?

    crime_application.investments.where(ownership_type: ownership_types)
  end

  def national_savings_certificates
    return [] unless requires_full_capital?

    crime_application.national_savings_certificates.where(ownership_type: ownership_types)
  end

  def has_national_savings_certificates
    super if requires_full_capital?
  end

  def has_no_properties
    super if requires_full_capital?
  end

  def has_no_savings
    super if requires_full_capital?
  end

  def has_no_investments
    super if requires_full_capital?
  end

  def has_premium_bonds
    super if requires_full_capital?
  end

  def partner_has_premium_bonds
    super if requires_full_capital?
  end

  def usual_property_details_required?
    return false unless FeatureFlags.property_ownership_validation.enabled?
    return false unless requires_full_capital?

    residence_type = ResidenceType.new(crime_application.applicant.residence_type)
    if residence_type.owned?
      return false if residence_type == ResidenceType::PARTNER_OWNED && !MeansStatus.include_partner?(crime_application)

      return crime_application.properties.home_address.blank?
    end

    false
  end

  private

  def confirmation_validator
    @confirmation_validator ||= CapitalAssessment::ConfirmationValidator.new(self)
  end

  def answers_validator
    @answers_validator ||= CapitalAssessment::AnswersValidator.new(record: self)
  end

  def requires_full_capital?
    @requires_full_capital ||= MeansStatus.full_capital_required?(crime_application)
  end
end
