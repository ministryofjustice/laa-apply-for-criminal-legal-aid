RSpec.shared_context 'with office code selected' do
  let(:selected_office_code) { '1A123B' }
  let(:set_office_codes) { %w[1K022G 2A555X 3B345C 4C567D] }

  before do
    # Assume we have a signed in Provider,
    # with a selected office account
    allow_any_instance_of(Provider).to receive_messages(
      selected_office_code: selected_office_code,
      office_codes: set_office_codes
    )
  end
end
