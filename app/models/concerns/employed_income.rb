module EmployedIncome
  extend ActiveSupport::Concern

  def client_employments
    employments.select { |e| e.ownership_type == OwnershipType::APPLICANT.to_s }
  end

  def partner_employments
    employments.select { |e| e.ownership_type == OwnershipType::PARTNER.to_s }
  end

  def client_employment_income
    income_payments.find do |payment|
      payment.payment_type == IncomePaymentType::EMPLOYMENT.to_s &&
        payment.ownership_type == OwnershipType::APPLICANT.to_s
    end
  end

  def partner_employment_income
    income_payments.find do |payment|
      payment.payment_type == IncomePaymentType::EMPLOYMENT.to_s &&
        payment.ownership_type == OwnershipType::PARTNER.to_s
    end
  end

  def client_work_benefits
    income_payments.find do |payment|
      payment.payment_type == IncomePaymentType::WORK_BENEFITS.to_s &&
        payment.ownership_type == OwnershipType::APPLICANT.to_s
    end
  end

  def partner_work_benefits
    income_payments.find do |payment|
      payment.payment_type == IncomePaymentType::WORK_BENEFITS.to_s &&
        payment.ownership_type == OwnershipType::PARTNER.to_s
    end
  end

  def employed_owners
    owners = []
    owners << OwnershipType::APPLICANT.to_s if client_employed?
    owners << OwnershipType::PARTNER.to_s if partner_employed?

    owners
  end

  # employed income payement types relevant to a given application based on the
  # extent of means assessment
  def employed_income_payment_types
    if known_to_be_full_means?
      [IncomePaymentType::WORK_BENEFITS.to_s]
    else
      [IncomePaymentType::EMPLOYMENT.to_s]
    end
  end

  # inverse of employment_income_payment_type
  def obsolete_employed_income_payment_types
    IncomePaymentType::EMPLOYED_INCOME_TYPES.map(&:to_s) - employed_income_payment_types
  end
end
