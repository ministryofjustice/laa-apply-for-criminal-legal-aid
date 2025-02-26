class SectionsCompletenessValidator
  include TypeOfMeansAssessment

  def initialize(record)
    @record = record
  end

  attr_reader :record
  alias crime_application record

  delegate :errors, to: :record

  def validate # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/MethodLength
    if client_details_complete?
      errors.add(:benefit_type, :incomplete) unless passporting_benefit_complete?
      errors.add(:case_details, :incomplete) unless kase&.complete?
      errors.add(:income_assessment, :incomplete) unless income_assessment_complete?
      errors.add(:outgoings_assessment, :incomplete) unless outgoings_assessment_complete?
      errors.add(:capital_assessment, :incomplete) unless capital_assessment_complete?
      errors.add(:partner_details, :incomplete) unless partner_detail_complete?
      errors.add(:interests_of_justice, :incomplete) unless interests_of_justice_complete?
      errors.add(:documents, :incomplete) unless evidence_upload_complete?
    else
      errors.add(:client_details, :incomplete)
    end

    errors.add :base, :incomplete_records unless errors.empty?
  end

  delegate :client_details_complete?, :passporting_benefit_complete?, to: :crime_application

  def partner_detail_complete?
    validator = PartnerDetails::AnswersValidator.new(record: partner_detail, crime_application: crime_application)

    return true unless validator.applicable?

    validator.complete?
  end

  def interests_of_justice_complete?
    validator = InterestsOfJustice::AnswersValidator.new(crime_application)

    return true unless validator.applicable?

    validator.complete?
  end

  def income_assessment_complete?
    return true unless requires_means_assessment?
    return false unless income

    income.complete?
  end

  def outgoings_assessment_complete?
    return false unless extent_of_means_assessment_determined?
    return true unless requires_full_means_assessment?
    return false unless outgoings

    outgoings.complete?
  end

  def capital_assessment_complete?
    return false unless extent_of_means_assessment_determined?
    return true unless requires_full_means_assessment?
    return false unless capital

    capital.complete?
  end

  def evidence_validator
    ::SupportingEvidence::AnswersValidator.new(record:, crime_application:)
  end

  def evidence_upload_complete?
    return true unless evidence_validator.applicable?

    evidence_validator.evidence_complete?
  end
end
