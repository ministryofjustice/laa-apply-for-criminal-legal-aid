module TypeOfMeansAssessment
  extend ActiveSupport::Concern

  delegate :kase, :income, :income_payments, :income_benefits, :capital, to: :crime_application

  def requires_full_means_assessment?
    if income_below_threshold? && no_frozen_assets?
      !(summary_only? || (no_property? && no_savings?))
    else
      true
    end
  end

  def requires_full_capital?
    [
      CaseType::EITHER_WAY,
      CaseType::INDICTABLE,
      CaseType::ALREADY_IN_CROWN_COURT
    ].include?(CaseType.new(kase.case_type))
  end

  private

  def summary_only?
    kase.case_type == CaseType::SUMMARY_ONLY.to_s
  end

  def no_property?
    income.client_owns_property == 'no'
  end

  def no_savings?
    income.has_savings == 'no'
  end

  def no_frozen_assets?
    income.has_frozen_income_or_assets == 'no'
  end

  def income_below_threshold?
    income&.income_above_threshold == 'no'
  end
end
