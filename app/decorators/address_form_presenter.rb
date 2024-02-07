class AddressFormPresenter < BasePresenter
  delegate :postcode, to: :record

  def page_title
    ".page_title.#{i18n_key}"
  end

  def heading
    ".heading.#{i18n_key}"
  end

  def home_address?
    record.is_a?(HomeAddress)
  end
  
  def partner_address?
    record.is_a?(PartnerAddress)
  end

  def addresses
    @addresses ||= begin
      results = super

      # Add the number of results as the first element of the collection
      # User has to select something, otherwise there is a validation error
      results.unshift(address_count_item) if results.any?
      results
    end
  end

  private

  def address_count_item
    Struct.new(:results_size, :lookup_id) do
      def compact_address
        I18n.translate!(:results_count, count: results_size, scope: 'steps.address.results.edit')
      end
    end.new(__getobj__.addresses.size)
  end

  def i18n_key
    variant.join('.')
  end

  def variant
    [record.person.type.underscore, record.type.underscore]
  end
end
