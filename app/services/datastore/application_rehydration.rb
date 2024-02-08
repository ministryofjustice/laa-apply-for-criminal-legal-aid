module Datastore
  class ApplicationRehydration
    attr_reader :crime_application, :parent

    def initialize(crime_application, parent:)
      @crime_application = crime_application
      @parent = Adapters::JsonApplication.new(parent)
    end

    def call # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      return if already_recreated?

      crime_application.update!(
        # TODO: Update partner rehydration when partner introduced and stored
        client_has_partner: client_has_partner,
        parent_id: parent.id,
        is_means_tested: means_tested,
        date_stamp: date_stamp,
        ioj_passport: parent.ioj_passport,
        means_passport: parent.means_passport,
        dependants: dependants,
        applicant: applicant,
        case: case_with_ioj,
        income: income,
        outgoings: outgoings,
        documents: parent.documents,
        additional_information: parent.additional_information
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
      parent.means_passport.include?('on_not_means_tested') ? YesNoAnswer::NO : YesNoAnswer::YES
    end

    def client_has_partner
      return if not_means_tested?

      YesNoAnswer::NO
    end

    # For re-hydration of returned applications, we keep the original
    # date stamp if the parent case type was date-stampable, otherwise
    # we leave it `nil`, so a new date is applied on resubmission.
    def date_stamp
      parent.date_stamp if not_means_tested? || CaseType.new(parent.case.case_type).date_stampable?
    end

    def applicant
      Applicant.new(parent.applicant.serializable_hash)
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
      parent.means_details&.income_details&.dependants&.map { |struct| Dependant.new(**struct) } || []
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

    def not_means_tested?
      return true if means_tested.value == :no

      false
    end
  end
end
