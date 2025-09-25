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
        new(office_code:).call
      end
    end
  end
end
