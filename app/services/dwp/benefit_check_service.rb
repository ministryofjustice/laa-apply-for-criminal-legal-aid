module DWP
  class BenefitCheckService
    BENEFIT_CHECKER_NAMESPACE = 'https://lsc.gov.uk/benefitchecker/service/1.0/API_1.0_Check'.freeze
    REQUEST_TIMEOUT = 30.seconds
    BENEFIT_CHECKER_RESPONSES = %w[Yes No Undetermined].freeze

    def initialize(person)
      @person = person
      @config = Rails.configuration.x.benefit_checker
    end

    def self.call(person)
      return MockBenefitCheckService.call(person) if use_mock?

      new(person).call
    end

    def self.passporting_benefit?(person)
      result = call(person)
      return result if result.nil?

      result[:benefit_checker_status].casecmp('yes').zero?
    end

    def self.benefit_check_result(person)
      result = call(person)
      return result if result.nil?

      return 'Undetermined' unless result[:benefit_checker_status].in?(BENEFIT_CHECKER_RESPONSES)

      result[:benefit_checker_status]
    end

    def self.use_mock?
      Rails.configuration.x.benefit_checker.use_mock.inquiry.true?
    end

    def call
      Rails.error.handle do
        soap_client.call(
          :check, message: benefit_checker_params
        ).body[:benefit_checker_response]
      end
    end

    private

    attr_reader :person, :config

    def benefit_checker_params
      {
        clientReference: person.crime_application_id,
        nino: person.nino,
        surname: person.last_name.strip.upcase,
        dateOfBirth: person.date_of_birth.strftime('%Y%m%d'),
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
