module CaseDetails
  class AnswersValidator
    def initialize(record)
      @record = record
    end

    attr_reader :record
    alias kase record

    delegate :errors, :crime_application, to: :kase

    # Adds the error to the first step name a user would need to go to
    # fix the issue.

    def validate # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      errors.add(:has_case_concluded, :blank) unless case_concluded_complete?

      unless not_means_tested?
        errors.add(:is_preorder_work_claimed, :blank) unless preorder_work_complete?
        errors.add(:is_client_remanded, :blank) unless client_remanded_complete?
      end

      errors.add(:charges, :blank) unless has_charges_complete?
      errors.add(:charges_summary, :incomplete_records) unless all_charges_complete?
      errors.add(:has_codefendants, :blank) unless has_codefendants_complete?
      errors.add(:codefendants_summary, :incomplete_records) unless all_codefendants_complete?
      errors.add(:hearing_details, :blank) unless hearing_details_complete?
      errors.add(:first_court_hearing, :blank) unless first_court_hearing_complete?

      errors.add :base, :incomplete_records unless errors.empty?
    end

    delegate :not_means_tested?, to: :crime_application

    def case_concluded_complete?
      return false if kase.has_case_concluded.blank?
      return true unless kase.has_case_concluded == 'yes'

      kase.date_case_concluded.present?
    end

    def preorder_work_complete?
      return true unless kase.has_case_concluded == 'yes'
      return true if kase.is_preorder_work_claimed == 'no'

      kase.values_at(
        :is_preorder_work_claimed,
        :preorder_work_date,
        :preorder_work_details
      ).all?(&:present?)
    end

    def client_remanded_complete?
      return false if kase.is_client_remanded.blank?
      return true if kase.is_client_remanded == 'no'

      kase.date_client_remanded.present?
    end

    def has_charges_complete?
      kase.charges.any?(&:complete?)
    end

    def all_charges_complete?
      kase.charges.all?(&:complete?)
    end

    def has_codefendants_complete?
      kase.has_codefendants.present?
    end

    def all_codefendants_complete?
      return true unless kase.has_codefendants == 'yes'

      kase.codefendants.any? && kase.codefendants.all?(&:complete?)
    end

    def hearing_details_complete?
      kase.values_at(:hearing_court_name, :hearing_date, :is_first_court_hearing).all?(&:present?)
    end

    def first_court_hearing_complete?
      return true unless kase.is_first_court_hearing == 'no'

      kase.first_court_hearing_name.present?
    end
  end
end
