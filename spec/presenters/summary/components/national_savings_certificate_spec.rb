require 'rails_helper'

RSpec.describe Summary::Components::NationalSavingsCertificate, type: :component do
  subject(:component) { render_summary_component(described_class.new(record:)) }

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
    context 'when show_record_actions set to false' do
      it 'show the "Edit" change link' do
        expect(page).to have_link(
          'Edit',
          href: '/applications/APP123/steps/capital/add-national-savings-certificates',
          exact_text: 'Edit National Savings Certificate'
        )
      end
    end

    context 'when show_record_actions true' do
      subject(:component) do
        render_summary_component(described_class.new(record: record, show_record_actions: true))
      end

      let(:path) { '/applications/APP123/steps/capital/national-savings-certificates/national_savings_certificate123' }

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
            'Remove', href: "#{path}/confirm-destroy", exact_text: 'Remove National Savings Certificate'
          )
        end
      end
    end
  end

  describe 'answers' do
    it 'renders as summary list' do
      expect(page).to have_summary_row(
        'Customer or holder number',
        'A1'
      )
      expect(page).to have_summary_row(
        'Certificate number',
        'B2'
      )
      expect(page).to have_summary_row(
        'Value',
        '£100'
      )
      expect(page).to have_summary_row(
        'Who owns the certificate?',
        'Client'
      )
    end

    context 'when value has non-zero amount in decimal place' do
      let(:attributes) do
        {
          id: 'national_savings_certificate123',
          crime_application_id: 'APP123',
          holder_number: 'A1',
          certificate_number: 'B2',
          value: 100.5,
          ownership_type: 'applicant'
        }
      end

      it 'renders as summary list with decimal place value present' do
        expect(page).to have_summary_row(
                          'Value',
                          '£100.50',
                          )
      end
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
          'Customer or holder number',
          ''
        )
        expect(page).to have_summary_row(
          'Certificate number',
          ''
        )
        expect(page).to have_summary_row(
          'Value',
          ''
        )
        expect(page).to have_summary_row(
          'Who owns the certificate?',
          ''
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
