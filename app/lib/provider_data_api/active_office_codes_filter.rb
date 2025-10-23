module ProviderDataApi
  class DefaultSchedulesToOfficeTranslator
    def active? = true

    def self.translate(_response) = new
  end

  class ActiveOfficeCodesFilter
    def initialize(office_codes: [], area_of_law: nil, http_client: nil, translator: nil)
      @office_codes = office_codes
      @area_of_law = Types::AreaOfLaw[area_of_law] if area_of_law
      @http_client = http_client || HttpClient.call
      @translator = translator || DefaultSchedulesToOfficeTranslator
    end

    # Filters a list of office codes to return only those that are active.
    # NB offices in Contingent Liability are considered active by PDA.
    # Using the default translator effectively proxies PDAs definition of
    # an active office
    def call
      office_codes.filter do |office_code|
        translator.translate(
          GetOfficeSchedules.call(office_code, area_of_law:)
        ).active?
      rescue RecordNotFound
        false
      end
    end

    class << self
      def call(office_codes, area_of_law: nil, translator: nil)
        translator ||= DefaultSchedulesToOfficeTranslator
        new(office_codes:, area_of_law:, translator:).call
      end
    end

    private

    attr_reader :office_codes, :http_client, :area_of_law, :translator
  end
end
