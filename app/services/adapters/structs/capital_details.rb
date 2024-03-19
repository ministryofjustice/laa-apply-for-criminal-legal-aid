module Adapters
  module Structs
    class CapitalDetails < BaseStructAdapter
      def savings
        return [] unless __getobj__

        super.map { |attrs| Saving.new(**attrs) }
      end

      def investments
        return [] unless __getobj__

        super.map { |attrs| Investment.new(**attrs) }
      end

      def national_savings_certificates
        return [] unless __getobj__

        super.map { |attrs| NationalSavingsCertificate.new(**attrs) }
      end

      def properties
        return [] unless __getobj__

        super.map do |attrs|
          attrs.property_owners.map! do |po|
            PropertyOwner.new(**po)
          end
          Property.new(**attrs)
        end
      end

      def serializable_hash(options = {})
        except = %i[savings investments national_savings_certificates properties]
        super options.merge(except:)
      end
    end
  end
end
