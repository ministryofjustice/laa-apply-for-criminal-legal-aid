module OrdnanceSurvey
  class AddressLookupResults
    LINE_ONE_PARTS = %w[SUB_BUILDING_NAME BUILDING_NUMBER BUILDING_NAME DEPARTMENT_NAME ORGANISATION_NAME].freeze
    LINE_TWO_PARTS = %w[DEPENDENT_THOROUGHFARE_NAME THOROUGHFARE_NAME].freeze
    DEFAULT_COUNTRY = 'UNITED KINGDOM'.freeze
    OTHER_TERRITORIES = ['ISLE OF MAN', 'JERSEY', 'GUERNSEY'].freeze

    Address = Struct.new(:address_line_one, :address_line_two, :city, :country, :postcode, :lookup_id) do
      def address_lines
        [address_line_one, address_line_two].compact_blank.join(', ')
      end
    end

    class << self
      def call(results)
        results.map do |result|
          map_to_address(result.fetch('DPA'))
        end
      end

      def map_to_address(result)
        Address.new(
          address_line(result.slice(*LINE_ONE_PARTS).values),
          address_line(result.slice(*LINE_TWO_PARTS).values),
          postal_town(result),
          country_name(result),
          postcode(result),
          lookup_id(result)
        )
      end

      def lookup_id(result)
        result.fetch('UDPRN')
      end

      def postcode(result)
        result.fetch('POSTCODE')
      end

      def postal_town(result)
        other_territory?(result) ? result.fetch('DEPENDENT_LOCALITY') : result.fetch('POST_TOWN')
      end

      def country_name(result)
        other_territory?(result) ? result.fetch('POST_TOWN') : DEFAULT_COUNTRY
      end

      def other_territory?(result)
        OTHER_TERRITORIES.include?(result.fetch('POST_TOWN'))
      end

      def address_line(values)
        values.compact_blank.join(', ')
      end
    end
  end
end
