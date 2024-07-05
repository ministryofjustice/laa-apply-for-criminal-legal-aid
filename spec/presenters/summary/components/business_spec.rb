require 'rails_helper'

RSpec.describe Summary::Components::Business, type: :component do
  subject(:component) { render_summary_component(described_class.new(record:)) }

  let(:record) do
    instance_double(
      Business,
      complete?: true,
      crime_application: crime_application,
      **attributes
    )
  end

  let(:crime_application) { instance_double(CrimeApplication, id: 'APP123') }

  let(:attributes) do
    {
      id: 'BUS345',
      business_type: BusinessType.values.first,
      ownership_type: 'applicant',
      trading_name: 'LAA LTD',
      address: {
        address_line_one: 'address_line_one_r',
        address_line_two: nil,
        city: 'city_r',
        country: 'country_r',
        postcode: 'postcode_r'
      },
      description: 'It is LAA',
      trading_start_date: Date.new(2000, 1, 2),
      has_additional_owners: 'yes',
      additional_owners: 'Ben, Kim, Ali',
      has_employees: 'yes',
      number_of_employees: 21,
      salary: AmountAndFrequency.new(
        amount: 90_001,
        frequency: 'weekly'
      ),
      total_income_share_sales: nil,
      percentage_profit_share: 100,
      turnover: AmountAndFrequency.new(
        amount: 9_001_012,
        frequency: 'annual'
      ),
      drawings: AmountAndFrequency.new(
        amount: 90,
        frequency: 'week'
      ),
      profit: AmountAndFrequency.new(
        amount: 303_000,
        frequency: 'annual'
      )
    }
  end

  before { component }

  describe 'actions' do
    context 'when show_record_actions set to false' do
      it 'show the "Edit" change link' do
        expect(page).to have_link(
          'Edit',
          href: '/applications/APP123/steps/income/client/businesses_summary'
        )
      end
    end

    context 'when show_record_actions true' do
      subject(:component) do
        render_summary_component(described_class.new(record: record, show_record_actions: true))
      end

      let(:path) { '/applications/APP123/steps/income/client/businesses/BUS345' }

      describe 'change link' do
        it 'show the correct change link' do
          expect(page).to have_link(
            'Change', href: path
          )
        end
      end

      describe 'remove link' do
        it 'show the correct remove link' do
          expect(page).to have_link(
            'Remove', href: "#{path}/confirm_destroy"
          )
        end
      end
    end
  end

  describe 'answers' do
    it 'renders as summary list' do # rubocop:disable RSpec/MultipleExpectations
      expect(page).to have_summary_row 'Trading name', 'LAA LTD'
      expect(page).to have_summary_row 'Business address', 'address_line_one_r, city_r, postcode_r, country_r'
      expect(page).to have_summary_row 'Date began trading', '2 January 2000'
      expect(page).to have_summary_row 'In business with anyone else?', 'Yes'
      expect(page).to have_summary_row 'Name of others', 'Ben, Kim, Ali'
      expect(page).to have_summary_row 'Employees?', 'Yes'
      expect(page).to have_summary_row 'Number of employees', '21'
      expect(page).to have_summary_row 'Total turnover', '£90,010.12 every year'
      expect(page).to have_summary_row 'Total drawings', '£0.90 every week'
      expect(page).to have_summary_row 'Total profit', '£3,030.00 every year'
    end

    context 'when answers are missing' do
      let(:attributes) do
        {
          id: 'BUS345',
          business_type: BusinessType.values.first,
          ownership_type: 'partner',
          trading_name: nil,
          address: {},
          description: nil,
          trading_start_date: nil,
          has_additional_owners: nil,
          additional_owners: 'Ben, Kim, Ali',
          has_employees: nil,
          number_of_employees: 21,
          salary: nil,
          total_income_share_sales: nil,
          percentage_profit_share: nil,
          turnover: nil,
          drawings:  AmountAndFrequency.new(amount: nil, frequency: 'week'),
          profit: AmountAndFrequency.new(amount: 303_000, frequency: nil)
        }
      end

      it 'renders as summary list' do # rubocop:disable RSpec/MultipleExpectations
        expect(page).to have_summary_row 'Trading name', ''
        expect(page).to have_summary_row 'Business address', ''
        expect(page).to have_summary_row 'Date began trading', ''
        expect(page).to have_summary_row 'In business with anyone else?', ''
        expect(page).not_to have_content 'Name of others'
        expect(page).to have_summary_row 'Employees?', ''
        expect(page).not_to have_content 'Number of employees'
        expect(page).to have_summary_row 'Total turnover', ''
        expect(page).to have_summary_row 'Total profit', ''
        expect(page).to have_summary_row 'Total drawings', ''
      end
    end
  end

  describe 'card heading' do
    subject(:heading) do
      page.first('h2.govuk-summary-card__title').text
    end

    it { is_expected.to eq 'Self-employed business' }
  end
end
