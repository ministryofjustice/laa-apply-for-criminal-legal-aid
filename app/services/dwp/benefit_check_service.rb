module DWP
  class BenefitCheckService
    BENEFIT_CHECKER_NAMESPACE = 'https://lsc.gov.uk/benefitchecker/service/1.0/API_1.0_Check'.freeze
    USE_MOCK = ActiveModel::Type::Boolean.new.cast(ENV.fetch('BC_USE_DEV_MOCK', nil))
    REQUEST_TIMEOUT = 30.seconds

    def initialize(applicant)
      @applicant = applicant
    end

    def self.call(applicant)
      return MockBenefitCheckService.call(applicant) if USE_MOCK

      new(applicant).call
    end

    def self.passporting_benefit?(applicant)
      result = call(applicant)
      return result if result.nil?

      result[:benefit_checker_status].casecmp('yes').zero?
    end

    def call
      soap_client.call(:check, message: benefit_checker_params).body[:benefit_checker_response]
    rescue StandardError => e
      Rails.logger.error(e)
      Sentry.capture_exception(e)
      nil
    end

    private

    attr_reader :applicant

    def benefit_checker_params
      {
        clientReference: applicant.crime_application_id,
        nino: applicant.nino,
        surname: applicant.last_name.strip.upcase,
        dateOfBirth: applicant.date_of_birth.strftime('%Y%m%d'),
        dateOfAward: Time.zone.today.strftime('%Y%m%d'),
      }.merge(credential_params)
    end

    def credential_params
      {
        lscServiceName: ENV.fetch('BC_LSC_SERVICE_NAME', nil),
        clientOrgId: ENV.fetch('BC_CLIENT_ORG_ID', nil),
        clientUserId: ENV.fetch('BC_CLIENT_USER_ID', nil),
      }
    end

    def soap_client
      @soap_client ||= Savon.client(
        endpoint: ENV.fetch('BC_WSDL_URL', nil),
        open_timeout: REQUEST_TIMEOUT,
        read_timeout: REQUEST_TIMEOUT,
        namespace: BENEFIT_CHECKER_NAMESPACE,
      )
    end
  end
end
