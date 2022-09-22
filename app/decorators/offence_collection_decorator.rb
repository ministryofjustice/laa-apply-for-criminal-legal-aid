class OffenceCollectionDecorator < BaseDecorator
  # We are using this decorator to build the datalist options
  # using the helper `options_from_collection_for_select`.
  def map
    super do |offence|
      yield OffencePresenter.present(offence)
    end
  end
end
