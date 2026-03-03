module Datastore
  # rubocop:disable Metrics/ClassLength
  class ApplicationRehydration
    attr_reader :crime_application, :parent

    def initialize(crime_application, parent:)
      @crime_application = crime_application
      @parent = Adapters::JsonApplication.new(parent)
    end

    def call # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      return if already_recreated?

      crime_application.update!(
        parent_id: parent.id,
        is_means_tested: parent.is_means_tested,
        date_stamp: date_stamp,
        date_stamp_context: parent.date_stamp_context,
        ioj_passport: parent.ioj_passport,
        means_passport: parent.means_passport,
        dependants: dependants,
        applicant: applicant,
        partner: partner,
        partner_detail: partner_detail,
        case: case_with_ioj,
        income: income,
        outgoings: outgoings,
        outgoings_payments: parent.outgoings&.outgoings_payments || [],
        documents: parent.documents,
        additional_information: parent.additional_information,
        income_payments: parent.income&.income_payments || [],
        income_benefits: parent.income&.income_benefits || [],
        employments: parent.income&.employments || [],
        businesses: parent.income&.businesses || [],
        capital: capital,
        savings: parent.capital&.savings || [],
        investments: parent.capital&.investments || [],
        national_savings_certificates: parent.capital&.national_savings_certificates || [],
        properties: parent.capital&.properties || [],
        evidence_last_run_at: evidence_last_run_at,
        evidence_prompts: evidence_prompts,

        # Change in Financial Circumstances specific fields
        pre_cifc_reference_number: parent.pre_cifc_reference_number,
        pre_cifc_maat_id: parent.pre_cifc_maat_id,
        pre_cifc_usn: parent.pre_cifc_usn,
        pre_cifc_reason: parent.pre_cifc_reason,
      )
    end

    private

    def already_recreated?
      crime_application.applicant.present?
    end

    def split_case?
      parent.return_details.reason.inquiry.split_case?
    end

    # For re-hydration of returned applications, we keep the original
    # date stamp if the parent case type was date-stampable, otherwise
    # we leave it `nil`, so a new date is applied on resubmission.
    def date_stamp
      parent.date_stamp if parent.non_means_tested? || CaseType.new(parent.case.case_type).date_stampable?
    end

    def applicant
      attributes_to_ignore = PartnerDetail.fields + %w[benefit_check_status]
      attributes = parent.applicant.serializable_hash.except!(*attributes_to_ignore)

      Applicant.new(attributes)
    end

    def partner
      return nil unless parent.applicant.has_partner == 'yes' && parent.partner

      attributes_to_ignore = PartnerDetail.fields + %w[benefit_check_status is_included_in_means_assessment]
      attributes = parent.partner.serializable_hash.except!(*attributes_to_ignore)
      Partner.new(attributes)
    end

    # NOTE: Actual partner_detail fields are mixed between the Applicant and Partner Structs
    def partner_detail
      fields_from_applicant = %w[has_partner relationship_to_partner relationship_status separation_date]
      from_applicant = parent.applicant.serializable_hash.slice(*fields_from_applicant)

      # :nocov:
      if parent.partner
        fields_from_partner = %w[involvement_in_case conflict_of_interest has_same_address_as_client]
        from_partner = parent.partner.serializable_hash.slice(*fields_from_partner)
        PartnerDetail.new({}.merge(from_applicant).merge(from_partner))
      else
        PartnerDetail.new({}.merge(from_applicant))
      end
      # :nocov:
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
      income_details = parent.means_details&.income_details

      return [] if income_details.blank? || income_details.dependants.blank?

      income_details.dependants.map do |struct|
        Dependant.new(**struct)
      end
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

    def evidence_last_run_at
      return nil unless parent&.evidence_details&.last_run_at

      parent.evidence_details.last_run_at
    end

    def evidence_prompts
      return [] unless parent&.evidence_details&.evidence_prompts

      parent.evidence_details.evidence_prompts
    end
  end
  # rubocop:enable Metrics/ClassLength
end
