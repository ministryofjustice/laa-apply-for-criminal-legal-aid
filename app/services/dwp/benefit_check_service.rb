module DWP
  class BenefitCheckService
    BENEFIT_CHECKER_NAMESPACE = 'https://lsc.gov.uk/benefitchecker/service/1.0/API_1.0_Check'.freeze
    REQUEST_TIMEOUT = 30.seconds

    def initialize(applicant)
      @applicant = applicant
      @config = Rails.configuration.x.benefit_checker
    end

    def self.call(applicant)
      return MockBenefitCheckService.call(applicant) if use_mock?

      new(applicant).call
    end

    def self.passporting_benefit?(applicant)
      result = call(applicant)
      return result if result.nil?

      result[:benefit_checker_status].casecmp('yes').zero?
    end

    def self.use_mock?
      ActiveModel::Type::Boolean.new.cast(Rails.configuration.x.benefit_checker.use_mock)
    end

    def call
      soap_client.call(:check, message: benefit_checker_params).body[:benefit_checker_response]
    rescue StandardError => e
      Rails.logger.error(e)
      Sentry.capture_exception(e)
      nil
    end

    private

    attr_reader :applicant, :config

    def benefit_checker_params
      {
        clientReference: applicant.id,
        nino: applicant.nino,
        surname: applicant.last_name.strip.upcase,
        dateOfBirth: applicant.date_of_birth.strftime('%Y%m%d'),
        dateOfAward: Time.zone.today.strftime('%Y%m%d'),
      }.merge(credential_params)
    end

    def credential_params
      {
        lscServiceName: config.lsc_service_name,
        clientOrgId: config.client_org_id,
        clientUserId: config.client_user_id,
      }
    end

    def soap_client
      @soap_client ||= Savon.client(
        endpoint: config.wsdl_url,
        open_timeout: REQUEST_TIMEOUT,
        read_timeout: REQUEST_TIMEOUT,
        namespace: BENEFIT_CHECKER_NAMESPACE,
      )
    end
  end
end
