RSpec.shared_context 'current provider with active office' do
  let(:selected_office_code) { '1A123B' }
  let(:set_office_codes) { %w[1K022G 2A555X 3B345C 4C567D] }

  let(:current_provider) do
    double(
      Provider,
      selected_office_code: selected_office_code,
      office_codes: set_office_codes
    )
  end

  let(:office_code) { selected_office_code } unless method_defined?(:existing_case)

  before do
    allow(controller).to receive(:current_provider).and_return(
      current_provider
    )
  end
end
