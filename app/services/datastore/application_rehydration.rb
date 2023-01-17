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
        date_stamp: parent.date_stamp,
        ioj_passport: parent.ioj_passport,
        applicant: applicant,
        case: kase,
      )
    end

    private

    def already_recreated?
      crime_application.applicant.present?
    end

    def applicant
      Applicant.new(parent.applicant.serializable_hash)
    end

    def kase
      Case.new(parent.case.serializable_hash)
    end
  end
end
