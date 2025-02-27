module CapybaraHelpers # rubocop:disable Metrics/ModuleLength
  def fill_in_date(date)
    fill_in('Day', with: date.mday)
    fill_in('Month', with: date.month)
    fill_in('Year', with: date.year)
  end

  def fill_date(question, with: nil)
    date = with || Time.zone.today

    within(find('legend', text: question).sibling('div.govuk-date-input')) do
      fill_in_date(date)
    end
  end

  # radio buttons
  def choose_answer(question, choice)
    q = find('legend', text: question).sibling('div.govuk-radios')

    within q do
      choose(choice)
    end
  end

  def choose_answer_all(question, choice)
    all('legend', text: question).each do |legend|
      within legend.sibling('div.govuk-radios') do
        choose(choice)
      end
    end
  end

  # check boxes
  def choose_answers(question, choices = [])
    q = page.find('legend', text: question).sibling('div.govuk-checkboxes')

    within q do
      choices.each do |choice|
        check(choice)
      end
    end
  end

  def save_and_continue
    click_button('Save and continue')
  end

  def summary_card(card_title)
    title = page.find(
      :xpath,
      "//h2[@class='govuk-summary-card__title' and text()='#{card_title}']"
    )

    title.ancestor('div.govuk-summary-card')
  end

  def within_card(card_title, &block)
    within(summary_card(card_title), &block)
  end

  def return_to_application_later(applicant: 'Jo Bloggs', time_lapsed: 1.week)
    click_link('Sign out')
    travel time_lapsed
    visit root_path
    click_button('Start now')
    choose('Yes')
    save_and_continue
    click_link(applicant)
  end

  def draft_age_passported_application(case_type:) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    click_link('Start an application')
    choose('New application')
    save_and_continue

    # edit (Task list)
    click_link('Client details')

    # steps/client/details
    fill_in('First name', with: 'Jo')
    fill_in('Last name', with: 'Bloggs')
    fill_date(
      'What is their date of birth?',
      with: Passporting::AGE_PASSPORTED_UNTIL.ago.to_date.next_day
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
    choose_answer('Is any other criminal case or charge against your client in progress?', 'No')
    save_and_continue

    # steps/case/hearing_details
    select('Derby Crown Court', from: 'What court is the hearing at?')
    fill_date('When is the next hearing?', with: 1.week.from_now.to_date)
    choose_answer('Did this court also hear the first hearing?', 'Yes')
    save_and_continue

    # steps/case/ioj_passport
    save_and_continue

    # steps/evidence/upload
    save_and_continue

    # steps/submission/more_information
    choose_answer('Do you want to add any other information?', 'No')
    save_and_continue

    # steps/submission/review
    save_and_continue

    # steps/submission/declaration
    fill_in('First name', with: 'Zoe')
    fill_in('Last name', with: 'Bar')
    fill_in('Telephone number', with: '07715339488')

    stub_request(:post, 'http://datastore-webmock/api/v1/applications')
      .with { |req|
      @submitted_body = req.body
      true
    }
  end

  def return_submitted_application
    submitted = JSON.parse(@submitted_body)['application']
    application_id = submitted.fetch('id')

    returned_application_body = submitted.merge(
      reviewed_at: Time.zone.now, status: 'returned',
      review_status: 'returned_to_provider',
      return_details: { reason: 'evidence_issue', details: 'Age is wrong' }
    )

    stub_request(:get, "http://datastore-webmock/api/v1/applications/#{application_id}")
      .to_return(body: returned_application_body.to_json)

    visit completed_crime_application_path(application_id)
  end
end
