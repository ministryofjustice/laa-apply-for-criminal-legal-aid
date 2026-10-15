module SelfAssessmentTaxBill
  def applicant_self_assessment_tax_bill
    return unless client_employed? || client_self_employed?

    super if known_to_be_full_means?
  end

  def partner_self_assessment_tax_bill
    return unless partner_employed? || partner_self_employed?
    return unless MeansStatus.include_partner?(crime_application)

    super if known_to_be_full_means?
  end

  def applicant_self_assessment_tax_bill_amount
    super if applicant_pays_self_assessment_tax_bill?
  end

  def applicant_self_assessment_tax_bill_frequency
    super if applicant_pays_self_assessment_tax_bill?
  end

  def partner_self_assessment_tax_bill_amount
    super if partner_pays_self_assessment_tax_bill?
  end

  def partner_self_assessment_tax_bill_frequency
    super if partner_pays_self_assessment_tax_bill?
  end

  private

  def applicant_pays_self_assessment_tax_bill?
    applicant_self_assessment_tax_bill == YesNoAnswer::YES.to_s
  end

  def partner_pays_self_assessment_tax_bill?
    partner_self_assessment_tax_bill == YesNoAnswer::YES.to_s
  end
end
