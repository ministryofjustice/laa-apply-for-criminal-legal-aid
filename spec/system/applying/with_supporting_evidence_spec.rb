require 'rails_helper'

RSpec.describe 'Supporting evidence' do
  include_context 'when logged in'

  context 'When NINO is missing' do
    let(:case_type) { 'Summary only' }

    before do
      # ClamAV is available
      allow(Open3).to receive(:capture3).and_return ['ClamAV', nil]

      click_link('Start an application')
      choose('New application')
      save_and_continue

      # edit (Task list)
      click_link('Client details')

      # steps/client/details
      fill_in('First name', with: 'Mo')
      fill_in('Last name', with: 'Kali')
      fill_date(
        'What is their date of birth?',
        with: Date.new(1999, 1, 12)
      )
      save_and_continue

      # steps/client/is_application_means_tested
      save_and_continue

      # steps/client/case_type
      choose(case_type)
      save_and_continue

      save_and_continue

      # steps/client/residence_type
      choose_answer(
        'Where does your client usually live?',
        'They do not have a fixed home address'
      )
      save_and_continue

      # steps/client/contact_details
      choose_answer('Where shall we send correspondence?', 'Provider’s office')
      save_and_continue

      # steps/client/urn
      save_and_continue

      # steps/client/nino
      choose_answer('Does your client have a National Insurance number?', 'No')
      save_and_continue

      # steps/client/does_client_have_partner
      choose_answer('Does your client have a partner?', 'No')
      save_and_continue

      # steps/client/relationship-status
      choose_answer("What is your client's relationship status?", 'They prefer not to say')
      save_and_continue

      # steps/dwp/benefit-type
      choose_answer(
        'Does your client get one of these passporting benefits?',
        'Universal Credit'
      )
      save_and_continue

      # steps/dwp/confirm-result
      choose('I will enter the National Insurance number later')

      click_button 'Save and come back later'

      # Task list
      click_link('Upload evidence')
    end

    it 'requires me to upload evidence' do # rubocop:disable RSpec/ExampleLength, RSpec/MultipleExpectations
      expect(page).to have_text(
        'Based on your answers, you need to provide the following evidence to support the application.'
      )

      expect(page).to have_text 'their National Insurance number'

      # Without a file attached
      save_and_continue

      expect(page).to have_step_error 'You must provide the required evidence'

      # With a fake pdf file
      upload_evidence_file('not_really.pdf')
      expect(page).to have_content(
        'File could not be uploaded – file must be a DOC, DOCX, RTF, ODT, JPG, BMP, PNG, TIF, CSV or PDF'
      )

      # With a small file
      upload_evidence_file('small.txt')
      expect(page).to have_content(
        'File could not be uploaded – file must be bigger than 3KB'
      )

      # With a pdf that fails the scan
      upload_evidence_file('fails_scan.pdf')
      expect(page).to have_content(
        'File could not be uploaded – try again'
      )

      save_and_continue
      expect(page).to have_step_error 'You must provide the required evidence'

      # A valid file
      upload_evidence_file('test.csv')
      save_and_continue

      expect(page).not_to have_step_error 'You must provide the required evidence'
    end
  end
end
