module Datastore
  # rubocop:disable Metrics/ClassLength
  class ApplicationRehydration
    attr_reader :crime_application, :parent

    def initialize(crime_application, parent:)
      @crime_application = crime_application
      @parent = Adapters::JsonApplication.new(parent)
    end

    def call # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      return if already_recreated?

      crime_application.update!(
        client_has_partner: client_has_partner,
        parent_id: parent.id,
        is_means_tested: means_tested,
        date_stamp: date_stamp,
        ioj_passport: parent.ioj_passport,
        means_passport: parent.means_passport,
        dependants: dependants,
        applicant: applicant,
        partner: partner,
        partner_detail: partner_detail,
        case: case_with_ioj,
        income: income,
        outgoings: outgoings,
        outgoings_payments: outgoings_payments,
        documents: parent.documents,
        additional_information: parent.additional_information,
        income_payments: income_payments,
        income_benefits: income_benefits,
        capital: capital,
        savings: capital ? parent.capital.savings : [],
        investments: capital ? parent.capital.investments : [],
        national_savings_certificates: capital ? parent.capital.national_savings_certificates : [],
        properties: capital ? parent.capital.properties : [],
        evidence_last_run_at: evidence_last_run_at,
        evidence_prompts: evidence_prompts
      )
    end

    private

    def already_recreated?
      crime_application.applicant.present?
    end

    def split_case?
      parent.return_details.reason.inquiry.split_case?
    end

    # `is_means_tested` is not part of Schema, requires calculation
    def means_tested
      return YesNoAnswer::YES unless FeatureFlags.non_means_tested.enabled?

      parent.means_passport.include?('on_not_means_tested') ? YesNoAnswer::NO : YesNoAnswer::YES
    end

    def client_has_partner
      parent.client_details.applicant.has_partner == 'yes' ? YesNoAnswer::YES : YesNoAnswer::NO
    end

    # For re-hydration of returned applications, we keep the original
    # date stamp if the parent case type was date-stampable, otherwise
    # we leave it `nil`, so a new date is applied on resubmission.
    def date_stamp
      parent.date_stamp if not_means_tested? || CaseType.new(parent.case.case_type).date_stampable?
    end

    def applicant
      attributes_to_ignore = PartnerDetail.fields + %w[benefit_check_status]
      attributes = parent.applicant.serializable_hash.except!(*attributes_to_ignore)

      Applicant.new(attributes)
    end

    def partner
      return nil unless FeatureFlags.partner_journey.enabled?
      return nil unless parent.partner && parent.applicant.has_partner == 'yes'

      attributes_to_ignore = PartnerDetail.fields + %w[benefit_check_status is_included_in_means_assessment]
      attributes = parent.partner.serializable_hash.except!(*attributes_to_ignore)
      Partner.new(attributes)
    end

    # NOTE: Actual partner_detail fields are mixed between the Applicant and Partner Structs
    def partner_detail
      return nil unless FeatureFlags.partner_journey.enabled?

      fields_from_applicant = %w[has_partner relationship_to_partner relationship_status separation_date]
      fields_from_partner = %w[involvement_in_case conflict_of_interest has_same_address_as_client]

      from_applicant = parent.applicant.serializable_hash.slice(*fields_from_applicant)
      from_partner = parent.partner.serializable_hash.slice(*fields_from_partner) if parent.partner

      PartnerDetail.new({}.merge(from_applicant).merge(from_partner))
    end

    def ioj
      if parent.ioj.present?
        Ioj.new(parent.ioj.serializable_hash)
      elsif split_case?
        Ioj.new(passport_override: true)
      end
    end

    def case_with_ioj
      Case.new(
        parent.case.serializable_hash.merge('ioj' => ioj)
      )
    end

    def dependants
      parent.means_details&.income_details&.dependants&.map do |struct|
        Dependant.new(**struct)
      end || []
    end

    def income_payments
      parent.means_details&.income_details&.income_payments&.map do |struct|
        IncomePayment.new(**struct)
      end || []
    end

    def income_benefits
      parent.means_details&.income_details&.income_benefits&.map do |struct|
        IncomeBenefit.new(**struct)
      end || []
    end

    def income
      return if parent.income.blank?

      Income.new(
        parent.income.serializable_hash
      )
    end

    def outgoings
      return if parent.outgoings.blank?

      Outgoings.new(parent.outgoings.serializable_hash)
    end

    def capital
      return if parent.capital.blank?

      Capital.new(parent.capital.serializable_hash)
    end

    def outgoings_payments
      parent.means_details&.outgoings_details&.outgoings&.map do |struct|
        OutgoingsPayment.new(**struct)
      end || []
    end

    def not_means_tested?
      return true if means_tested.value == :no

      false
    end

    def evidence_last_run_at
      return [] unless parent&.evidence_details&.last_run_at

      parent.evidence_details.last_run_at
    end

    def evidence_prompts
      return [] unless parent&.evidence_details&.evidence_prompts

      parent.evidence_details.evidence_prompts
    end
  end
  # rubocop:enable Metrics/ClassLength
end
