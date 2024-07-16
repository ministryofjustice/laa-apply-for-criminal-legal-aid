module SupportingEvidence
  class AnswersValidator < BaseAnswerValidator
    include TypeOfMeansAssessment

    attr_reader :record
    alias crime_application record

    def complete?
      validate
      errors.empty?
    end

    def applicable?
      true
    end

    def validate
      errors.add(:documents, :blank) unless evidence_complete?
    end

    def evidence_complete?
      return true if exempt?

      evidence_present?
    end

    # TODO: add branch for CIFC applications
    def exempt?
      return true unless evidence_required?
      return true if indictable_or_in_crown_court?

      nino_is_only_evidence_prompt && has_passporting_benefit? && client_remanded_in_custody?
    end

    def client_remanded_in_custody?
      return true unless kase

      kase.is_client_remanded == 'yes' && kase.date_client_remanded.present?
    end

    def indictable_or_in_crown_court?
      return true unless kase

      [CaseType::INDICTABLE.to_s, CaseType::ALREADY_IN_CROWN_COURT.to_s]
        .include?(kase&.case_type)
    end

    def evidence_required?
      evidence_prompt_results.uniq.any?
    end

    def evidence_prompt_count
      evidence_prompt_results.count(true)
    end

    def nino_is_only_evidence_prompt
      nino_evidence_required? && (evidence_prompt_count == 1)
    end

    # rubocop:disable Layout/LineLength
    def nino_evidence_required?
      record.evidence_prompts.first { |result| result['key'] == :national_insurance_32 }['run'].slice('client', 'partner', 'other').values.pluck('result').flatten.uniq.any?
    end

    def evidence_prompt_results
      record.evidence_prompts.map { |result| result['run'].slice('client', 'partner', 'other') }.map { |e| e.values.pluck('result') }.flatten
    end
    # rubocop:enable Layout/LineLength

    def evidence_present?
      record.documents.stored.any?
    end
  end
end
