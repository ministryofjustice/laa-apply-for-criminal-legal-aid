require 'rails_helper'

RSpec.describe Summary::Components::Employment, type: :component do
  subject(:component) { render_summary_component(described_class.new(record:)) }

  let(:record) {
    instance_double(Employment,
                    complete?: true,
                    deductions: deductions,
                    has_no_deductions: has_no_deductions,
                    crime_application: crime_application, **attributes,
                    ownership_type: 'applicant')
  }

  let(:deduction1) {
    instance_double(Deduction,
                    deduction_type: 'income_tax',
                    amount: 500,
                    other?: false,
                    frequency: 'week',
                    details: nil)
  }

  let(:deduction2) {
    instance_double(Deduction,
                    deduction_type: 'other',
                    amount: 700,
                    other?: true,
                    frequency: 'week',
                    details: 'deduction details')
  }

  let(:crime_application) { instance_double(CrimeApplication, id: 'APP123') }

  let(:attributes) do
    {
      id: 'EMPLOYMENT123',
      crime_application_id: 'APP123',
      employer_name: 'Rick',
      job_title: 'Manager',
      amount: 1700,
      frequency: 'week',
      address: { 'city' => 'london', 'country' => 'United Kingdom', 'postcode' => 'TW7' }
    }
  end

  let(:has_no_deductions) { nil }
  let(:deductions) { [deduction1, deduction2] }

  before { component }

  describe 'actions' do
    context 'when show_record_actions set to false' do
      it 'show the "Edit" change link' do
        expect(page).to have_link(
          'Edit',
          href: '/applications/APP123/steps/income/client/add-employments?employment_id=EMPLOYMENT123',
          exact_text: 'Edit Job'
        )
      end
    end

    context 'when show_record_actions true' do
      subject(:component) { render_summary_component(described_class.new(record: record, show_record_actions: true)) }

      describe 'change link' do
        it 'show the correct change link' do
          expect(page).to have_link(
            'Change',
            href: '/applications/APP123/steps/income/client/employer-details/EMPLOYMENT123',
            exact_text: 'Change Job'
          )
        end
      end

      describe 'remove link' do
        it 'show the correct remove link' do
          expect(page).to have_link(
            'Remove',
            href: '/applications/APP123/steps/income/client/employments/EMPLOYMENT123/confirm-destroy',
            exact_text: 'Remove Job'
          )
        end
      end
    end
  end

  describe 'answers' do
    it 'renders as summary list' do
      expect(page).to have_summary_row(
        'Employer’s name',
        'Rick'
      )
      expect(page).to have_summary_row(
        'Job title',
        'Manager',
      )
      expect(page).to have_summary_row(
        'Employer’s address',
        'london TW7 United Kingdom',
      )
      expect(page).to have_summary_row(
        'Salary or wage',
        '£1,700.00 every week',
      )
    end

    context 'when employment has deductions' do
      it 'renders as summary list with other deductions' do
        expect(page).to have_summary_row(
          'Income Tax',
          '£500.00 every week',
        )
        expect(page).to have_summary_row(
          'Other deductions total',
          '£700.00 every week',
        )
        expect(page).to have_summary_row(
          'Details of other deductions',
          'deduction details',
        )
      end
    end

    context 'when employment has no deductions' do
      let(:has_no_deductions) { 'yes' }
      let(:deductions) { [] }

      it 'renders as summary list with other deductions' do
        expect(page).to have_summary_row(
          'Deductions',
          'None',
        )
      end
    end

    context 'when answers are missing' do
      let(:attributes) do
        {
          id: 'EMPLOYMENT123',
          crime_application_id: 'APP123',
          employer_name: nil,
          job_title: nil,
          amount: nil,
          frequency: nil,
          address: nil
        }
      end

      it 'renders as summary list with the correct absence_answer' do
        expect(page).to have_summary_row(
          'Employer’s name',
          ''
        )
        expect(page).to have_summary_row(
          'Job title',
          '',
        )
        expect(page).to have_summary_row(
          'Employer’s address',
          '',
        )
        expect(page).to have_summary_row(
          'Salary or wage',
          '',
        )
      end
    end
  end

  describe 'card heading' do
    subject(:heading) do
      page.first('h2.govuk-summary-card__title').text
    end

    it { is_expected.to eq 'Job' }
  end
end
