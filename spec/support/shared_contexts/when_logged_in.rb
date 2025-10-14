RSpec.shared_context 'when logged in' do
  let(:office_code) { '2A555X' }

  include_context 'with mock provider data'

  before do
    visit root_path
    click_button('Start now')

    # steps/provider/select_office
    choose(office_code)
    # prevent requests to the datastore for counters for tab headings on the next page
    allow_any_instance_of(Datastore::ApplicationCounters).to receive_messages(returned_count: 0)
    save_and_continue
  end
end
