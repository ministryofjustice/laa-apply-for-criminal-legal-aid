module Providers
  class MockGetActiveOffice
    OFFICES = {
      '1A123B' => { contingent_liability?: false },
      '4C567D' => { contingent_liability?: true },
      '3B345C' => { contingent_liability?: true },
      '2A555X' => { contingent_liability?: false }
    }.freeze

    def initialize(office_code:)
      @office_code = office_code
    end

    def call
      Office.new(office_code: office_code, active?: true, **OFFICES.fetch(@office_code))
    rescue KeyError
      raise Errors::OfficeNotFound
    end

    class << self
      def call(office_code)
        new(office_code:).call
      end
    end

    private

    attr_reader :office_code
  end
end
