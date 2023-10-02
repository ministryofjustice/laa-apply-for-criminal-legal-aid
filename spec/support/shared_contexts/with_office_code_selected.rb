RSpec.shared_context 'with office code selected' do
  let(:selected_office_code) { '1A123B' }

  before do
    # Assume we have a signed in Provider,
    # with a selected office account
    allow_any_instance_of(Provider).to receive(:selected_office_code)
      .and_return(selected_office_code)
  end
end
