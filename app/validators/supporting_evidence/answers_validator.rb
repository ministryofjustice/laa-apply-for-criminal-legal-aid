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
      return true if benefit_evidence_forthcoming? || record.cifc?

      !(indictable_or_in_crown_court? || client_remanded_in_custody?)
    end

    def validate
      errors.add(:documents, :blank) unless evidence_complete?
    end

    def evidence_complete?
      return false if (benefit_evidence_forthcoming? || record.cifc?) && !evidence_present?
      return true unless evidence_prompts_present?
      return true if nino_is_only_evidence_prompt && !has_passporting_benefit?

      evidence_present?
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

    def evidence_prompts_present?
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
      record.evidence_prompts.find { |result| result['key'] == 'national_insurance_32' }['run'].slice('client', 'partner', 'other').values.pluck('result').flatten.uniq.any?
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
