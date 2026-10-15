require 'rails_helper'

RSpec.describe 'Self Assessment payment questions' do
  include_context 'when logged in'

  let(:crime_application) do
    CrimeApplication.create!(
      office_code: office_code,
      applicant: Applicant.new(first_name: 'Jo', last_name: 'Bloggs', date_of_birth: Date.new(1990, 1, 1)),
      partner: Partner.new,
      partner_detail: PartnerDetail.new(involvement_in_case: 'none'),
      income: Income.new(employment_status: ['employed'], partner_employment_status: ['self_employed'])
    )
  end

  before do
    allow(MeansStatus).to receive_messages(full_means_required?: true, include_partner?: true)
  end

  %w[client partner].each do |person|
    context "for the #{person}" do
      let(:payment_heading) do
        "Payments for #{person == 'client' ? 'your client’s' : 'the partner’s'} " \
          'Self Assessment tax calculation received in the last 2 years'
      end

      before do
        visit public_send("edit_steps_income_#{person}_self_assessment_tax_bill_path", id: crime_application)
      end

      it 'only renders the two yes/no radios, including after Yes is selected' do
        choose('Yes')
        expect(page).to have_css('input[type="radio"]', count: 2, visible: :all)
        expect(page).to have_no_field('How much do they pay?', visible: :all)
        expect(page).to have_no_css('.govuk-radios__conditional', visible: :all)
      end

      it 'skips payment details for No' do
        choose('No')
        save_and_continue
        expect(page).to have_current_path(
          public_send("edit_steps_income_#{person}_other_work_benefits_path", id: crime_application)
        )
      end

      it 'asks for amount and frequency on a separate page for Yes' do
        choose('Yes')
        save_and_continue
        expect(page).to have_css('h1', exact_text: payment_heading)
        expect(page).to have_title(payment_heading.tr('’', "'"))
        expect(page).to have_current_path(
          public_send("edit_steps_income_#{person}_self_assessment_tax_bill_payment_path", id: crime_application)
        )
        fill_in('How much do they pay?', with: '123.45')
        choose_answer('How often do they pay this amount?', 'Monthly')
        save_and_continue
        expect(page).to have_current_path(
          public_send("edit_steps_income_#{person}_other_work_benefits_path", id: crime_application)
        )
      end

      it 'links payment validation errors to fields on the new page' do
        choose('Yes')
        save_and_continue
        save_and_continue

        within('.govuk-error-summary') do
          expect(page).to have_link('Enter the amount they pay')
          expect(page).to have_link('Select how often they pay this amount')
        end
      end

      it 'saves and restores an incomplete payment draft' do
        choose('Yes')
        save_and_continue
        payment_path = current_path
        fill_in('How much do they pay?', with: '123.45')
        click_button('Save and come back later')

        visit payment_path
        expect(page).to have_field('How much do they pay?', with: '123.45')
      end

      it 'preserves payment details when navigating back and changing Yes to No to Yes' do
        question_path = current_path
        choose('Yes')
        save_and_continue
        fill_in('How much do they pay?', with: '123.45')
        choose_answer('How often do they pay this amount?', 'Monthly')
        save_and_continue

        click_link('Back')
        expect(page).to have_field('How much do they pay?', with: '123.45')
        click_link('Back')
        expect(page).to have_current_path(question_path)
        choose('No')
        save_and_continue

        click_link('Back')
        expect(page).to have_current_path(question_path)
        choose('Yes')
        save_and_continue
        expect(page).to have_field('How much do they pay?', with: '123.45')
        expect(page).to have_checked_field('Monthly')
      end
    end
  end
end
