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
        ioj_passport: parent.ioj_passport,
        applicant: applicant,
      )
    end

    private

    def already_recreated?
      crime_application.applicant.present?
    end

    def applicant
      Applicant.new(parent.applicant.serializable_hash)
    end
  end
end
