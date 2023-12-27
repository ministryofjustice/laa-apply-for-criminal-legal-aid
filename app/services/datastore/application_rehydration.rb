module Datastore
  class ApplicationRehydration
    attr_reader :crime_application, :parent

    def initialize(crime_application, parent:)
      @crime_application = crime_application
      @parent = Adapters::JsonApplication.new(parent)
    end

    def call # rubocop:disable Metrics/MethodLength
      return if already_recreated?

      crime_application.update!(
        # TODO: Update partner rehydration when partner introduced and stored
        client_has_partner: YesNoAnswer::NO,
        parent_id: parent.id,
        date_stamp: date_stamp,
        ioj_passport: parent.ioj_passport,
        means_passport: parent.means_passport,
        applicant: applicant,
        case: case_with_ioj,
        income: income,
        dependants: dependants,
        outgoings: outgoings,
        documents: parent.documents,
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
      parent.date_stamp if CaseType.new(parent.case.case_type).date_stampable?
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

    # `client_has_dependants` is not part of Schema, requires calculation
    def income
      return if parent.income.blank?

      Income.new(
        parent.income.serializable_hash.merge(
          'client_has_dependants' => client_has_dependants
        )
      )
    end

    def dependants
      parent.means_details&.income_details&.dependants&.map { |struct| Dependant.new(**struct) } || []
    end

    def client_has_dependants
      parent.means_details&.income_details&.dependants&.any? ? YesNoAnswer::YES : YesNoAnswer::NO
    end

    def outgoings
      return if parent.outgoings.blank?

      Outgoings.new(parent.outgoings.serializable_hash)
    end
  end
end
