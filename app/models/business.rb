class Business < ApplicationRecord
  belongs_to :crime_application

  store_accessor :address, :address_line_one, :address_line_two, :city, :country, :postcode

  attribute :turnover, :amount_and_frequency
  attribute :drawings, :amount_and_frequency
  attribute :profit, :amount_and_frequency

  OPTIONAL_ADDRESS_ATTRIBUTES = %w[address_line_two].freeze
  REQUIRED_ADDRESS_ATTRIBUTES = Address::ADDRESS_ATTRIBUTES.map(&:to_s).reject { |a| a.in? OPTIONAL_ADDRESS_ATTRIBUTES }

  # TODO: add validation for upcoming screens, CRIMAPP-983, 984, 985
  def complete?
    except = %i[id crime_application_id created_at updated_at address_line_two percentage_profit_share salary
                total_income_share_sales]
    except << :number_of_employees if has_employees == YesNoAnswer::NO.to_s
    except << :additional_owners if has_additional_owners == YesNoAnswer::NO.to_s

    serializable_hash(except:).values.none?(&:blank?) && address_complete?
  end

  def address_complete?
    address.present? && address.values_at(*REQUIRED_ADDRESS_ATTRIBUTES.map(&:to_s)).all?(&:present?)
  end

  def owner
    return nil unless ownership_type

    if ownership_type == 'partner'
      crime_application.partner
    else
      crime_application.applicant
    end
  end

  def serializable_hash(options = nil)
    options ||= { except: [:created_at, :updated_at, :crime_application_id] }
    super
  end
end
