module Datastore
  class ApplicationRehydration
    attr_reader :crime_application, :parent

    def initialize(crime_application, parent:)
      @crime_application = crime_application
      @parent = Adapters::JsonApplication.new(parent)
    end

    def call
      return if already_recreated?

      crime_application.update!(
        client_has_partner: YesNoAnswer::NO,
        parent_id: parent.id,
        date_stamp: parent.date_stamp,
        ioj_passport: parent.ioj_passport,
        applicant: applicant,
        case: case_with_ioj,
      )
    end

    private

    def already_recreated?
      crime_application.applicant.present?
    end

    def applicant
      Applicant.new(parent.applicant.serializable_hash)
    end

    def ioj
      Ioj.new(parent.ioj.serializable_hash) if parent.ioj.present?
    end

    def case_with_ioj
      Case.new(
        parent.case.serializable_hash.merge('ioj' => ioj)
      )
    end
  end
end
