module Providers
  class GetActiveOffice
    def initialize(office_code:)
      @office_code = office_code
    end

    def call
      office = SchedulesToOfficeTranslator.translate(
        ProviderDataApi::GetOfficeSchedules.call(
          @office_code, area_of_law: 'CRIME LOWER'
        )
      )
      raise Errors::OfficeNotFound unless office.active?

      office
    rescue ProviderDataApi::RecordNotFound
      raise Errors::OfficeNotFound
    end

    class << self
      def call(office_code)
        return MockGetActiveOffice.call(office_code) if use_mock?

        new(office_code:).call
      end

      def use_mock?
        Rails.configuration.x.provider_data_api.use_mock.inquiry.true?
      end
    end
  end
end
