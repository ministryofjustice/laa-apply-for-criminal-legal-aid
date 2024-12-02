RSpec.shared_context 'means tested with partner' do
  let(:case_type) { 'Indictable' }
  let(:full_means_assessment?) { true }

  include_context 'when logged in'

  before do
    # applications
    click_link('Start an application')
    choose('New application')
    save_and_continue

    # edit (Task list)
    click_link('Client details')

    # steps/client/details
    fill_in('First name', with: 'Jo')
    fill_in('Last name', with: 'Bloggs')
    fill_date('Date of birth', with: 19.years.ago.to_date)
    save_and_continue

    # steps/client/is_application_means_tested
    save_and_continue

    # steps/client/case_type
    choose(case_type)
    save_and_continue

    # steps/client/date_stamp
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

    # steps/client/nino
    choose_answer('Does your client have a National Insurance number?', 'No')
    save_and_continue

    # steps/client/does_client_have_partner
    choose_answer('Does your client have a partner?', 'Yes')
    save_and_continue

    # steps/client/client_relationship_to_partner
    choose_answer('What is your client’s relationship to their partner?', 'Living together')
    save_and_continue

    # steps/partner/partner_details
    fill_in('First name', with: 'John')
    fill_in('Last name', with: 'Huffman')
    fill_date("What is the partner's date of birth?", with: 19.years.ago.to_date)
    save_and_continue

    # steps/partner/partner_involved_in_case
    choose_answer('Is the partner involved in your client’s case?', 'No, the partner is not involved')
    save_and_continue

    # steps/partner/nino
    choose_answer('Does the partner have a National Insurance number?', 'No')
    save_and_continue

    # steps/partner/do_client_and_partner_live_same_address
    choose_answer('Do your client and their partner live at the same address?', 'Yes')
    save_and_continue

    # steps/dwp/benefit_type
    choose_answer('Does your client get one of these passporting benefits?', 'None of these')
    save_and_continue

    # steps/dwp/partner_benefit_type
    choose_answer('Does the partner get one of these passporting benefits?', 'None of these')
    save_and_continue

    # steps/client/urn
    save_and_continue

    # steps/case/has_the_case_concluded
    choose_answer('Has the case concluded?', 'No')
    save_and_continue

    # steps/case/haas_court_remanded_client_in_custody
    choose_answer('Has a court remanded your client in custody?', 'No')
    save_and_continue

    # steps/case/charges/#{charge_id}
    fill_in('Offence', with: 'Theft from a shop (Over £100,000)')
    fill_date('Start date 1', with: 1.month.ago.to_date)
    save_and_continue

    # steps/case/charges_summary
    choose_answer('Do you want to add another offence?', 'No')
    save_and_continue

    # steps/case/has_codefendants
    choose_answer('Does your client have any co-defendants in this case?', 'No')
    save_and_continue

    # steps/case/client/other_charge_in_progress
    if full_means_assessment?
      choose_answer('Is any other criminal case or charge against your client in progress?', 'No')
      save_and_continue
    end

    # steps/case/hearing_details
    select('Derby Crown Court', from: 'What court is the hearing at?')
    fill_date('When is the next hearing?', with: 1.week.from_now.to_date)
    choose_answer('Did this court also hear the first hearing?', 'Yes')
    save_and_continue

    # steps/case/ioj_passport
    choose_answers(
      'Why should your client get legal aid?',
      ['It is likely that they will lose their livelihood']
    )
    fill_in(
      'steps-case-ioj-form-loss-of-livelihood-justification-field',
      with: 'IoJ justification details'
    )
    save_and_continue
  end
end
