require 'rails_helper'

RSpec.describe Summary::Components::NationalSavingsCertificate, type: :component do
  subject(:component) { render_inline(described_class.new(record:)) }

  let(:record) do
    instance_double(
      NationalSavingsCertificate,
      complete?: true,
      crime_application: crime_application,
      **attributes
    )
  end

  let(:crime_application) { instance_double(CrimeApplication, id: 'APP123') }

  let(:attributes) do
    {
      id: 'national_savings_certificate123',
      crime_application_id: 'APP123',
      holder_number: 'A1',
      certificate_number: 'B2',
      value: 100,
      ownership_type: 'applicant'
    }
  end

  before { component }

  describe 'actions' do
    let(:path) { '/applications/APP123/steps/capital/national_savings_certificates/national_savings_certificate123' }

    describe 'change link' do
      it 'show the correct change link' do
        expect(page).to have_link(
          'Change', href: path, exact_text: 'Change National Savings Certificate'
        )
      end
    end

    describe 'remove link' do
      it 'show the correct remove link' do
        expect(page).to have_link(
          'Remove', href: "#{path}/confirm_destroy", exact_text: 'Remove National Savings Certificate'
        )
      end
    end
  end

  describe 'answers' do
    it 'renders as summary list' do
      expect(page).to have_summary_row(
        'What is the customer number or holder number?',
        'A1'
      )
      expect(page).to have_summary_row(
        'What is the certificate number?',
        'B2'
      )
      expect(page).to have_summary_row(
        'What is the value of the certificate?',
        '£100.00'
      )
      expect(page).to have_summary_row(
        'Whose name is the certificate in?',
        'Client'
      )
    end

    context 'when answers are missing' do
      let(:attributes) do
        {

          id: 'national_savings_certificate123',
          crime_application_id: 'APP123',
          holder_number: nil,
          certificate_number: nil,
          value: nil,
          ownership_type: nil
        }
      end

      it 'renders as summary list with the correct absence_answer' do
        expect(page).to have_summary_row(
          'What is the customer number or holder number?',
          'None'
        )
        expect(page).to have_summary_row(
          'What is the certificate number?',
          'None'
        )
        expect(page).to have_summary_row(
          'What is the value of the certificate?',
          'None'
        )
        expect(page).to have_summary_row(
          'Whose name is the certificate in?',
          'None'
        )
      end
    end
  end

  describe 'card heading' do
    subject(:heading) do
      page.first('h2.govuk-summary-card__title').text
    end

    it { is_expected.to eq 'National Savings Certificate' }
  end
end
