module Adapters
  module Structs
    class CapitalDetails < BaseStructAdapter
      include PersonCapitalAssets

      def trust_fund_amount_held
        Money.new(super)
      end

      def trust_fund_yearly_dividend
        Money.new(super)
      end

      def partner_trust_fund_amount_held
        Money.new(super)
      end

      def partner_trust_fund_yearly_dividend
        Money.new(super)
      end

      def premium_bonds_total_value
        Money.new(super)
      end

      def partner_premium_bonds_total_value
        Money.new(super)
      end

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
          if attrs.respond_to?(:property_owners)
            attrs.property_owners.map! do |po|
              PropertyOwner.new(**po)
            end
          end
          Property.new(**attrs)
        end
      end

      def serializable_hash(options = {})
        except = %i[savings investments national_savings_certificates properties]
        super(options.merge(except:))
      end
    end
  end
end
