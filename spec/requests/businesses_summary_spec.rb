require 'rails_helper'

RSpec.describe 'Businesses summary page', :authorized do
  before do
    business = Business.new(
      'additional_owners' => '',
      'address' => {
        'address_line_one' => 'address_line_one_r',
        'address_line_two' => 'address_line_two_r',
        'city' => 'city_r',
        'country' => 'country_r',
        'postcode' => 'postcode_r'
      },
      'business_type' => 'self_employed',
      'description' => 'It is LAA',
      'drawings' => { 'amount' => 90, 'frequency' => 'week' },
      'has_additional_owners' => 'no',
      'has_employees' => 'no',
      'id' => nil,
      'number_of_employees' => 2,
      'ownership_type' => 'applicant',
      'percentage_profit_share' => 100.0,
      'profit' => {
        'amount' => 900_000,
        'frequency' => 'annual'
      },
      'salary' => {
        'amount' => 90_000,
        'frequency' => 'week'
      },
      'total_income_share_sales' => nil,
      'trading_name' => 'Client Business LTD',
      'trading_start_date' => '2000-01-02',
      'turnover' => {
        'amount' => 9_000_000,
        'frequency' => 'annual'
      }
    )

    partner_business = Business.new(
      'additional_owners' => '',
      'address' => {
        'address_line_one' => 'address_line_one_r',
        'address_line_two' => 'address_line_two_r',
        'city' => 'city_r',
        'country' => 'country_r',
        'postcode' => 'postcode_r'
      },
      'business_type' => 'self_employed',
      'description' => 'It is LAA',
      'drawings' => { 'amount' => 90, 'frequency' => 'week' },
      'has_additional_owners' => 'no',
      'has_employees' => 'no',
      'id' => nil,
      'number_of_employees' => 2,
      'ownership_type' => 'partner',
      'percentage_profit_share' => 100.0,
      'profit' => {
        'amount' => 900_000,
        'frequency' => 'annual'
      },
      'salary' => {
        'amount' => 90_000,
        'frequency' => 'week'
      },
      'total_income_share_sales' => nil,
      'trading_name' => 'Partner Business LTD',
      'trading_start_date' => '2000-01-02',
      'turnover' => {
        'amount' => 9_000_000,
        'frequency' => 'annual'
      }
    )

    CrimeApplication.create(
      income: Income.new,
      applicant: Applicant.new,
      partner: Partner.new,
      partner_detail: PartnerDetail.new(involvement_in_case: 'none'),
      businesses: [business, partner_business]
    )
  end

  let(:crime_application) { CrimeApplication.first }

  describe 'list of added businesses in summary page' do
    before do
      PartnerDetail.update_all(involvement_in_case:) # rubocop:disable Rails/SkipsModelValidations

      get edit_steps_income_businesses_summary_path(crime_application, subject: subject_type)
    end

    context 'when subject is client' do
      let(:involvement_in_case) { 'none' }
      let(:subject_type) { SubjectType::APPLICANT }

      it 'lists the businesses with their details and action links' do
        expect(response).to have_http_status(:success)
        # summary card details tested in the Summary::Components::Business spec
        assert_select 'h1', 'You added 1 business'
        assert_select '.govuk-summary-list__value', 'Client Business LTD'

        # confirm action are shown
        assert_select 'li.govuk-summary-card__action', count: 2
      end
    end

    context 'when subject is partner' do
      let(:subject_type) { SubjectType::PARTNER }
      let(:involvement_in_case) { 'none' }

      it 'lists the partners businesses' do
        expect(response).to have_http_status(:success)
        assert_select 'h1', 'You added 1 business'
        assert_select '.govuk-summary-list__value', 'Partner Business LTD'
      end

      context 'when partner has a contrary interest' do
        let(:involvement_in_case) { 'victim' }

        it 'redirects page not found' do
          expect(response).to redirect_to(/not-found/)
        end
      end
    end
  end

  describe 'delete a business' do
    let(:business) { Business.where(ownership_type: 'applicant').first }

    before do
      get confirm_destroy_steps_income_businesses_path(
        id: crime_application, business_id: business, subject: 'client'
      )
    end

    it 'allows a user to confirm before deleting a business' do
      expect(response).to have_http_status(:success)
      # summary card details tested in the Summary::Components::Business spec
      assert_select '.govuk-summary-card'
      # confirm action are not shown
      assert_select 'li.govuk-summary-card__action', count: 0

      expect(response.body).to include('Are you sure you want to remove this business?')
      expect(response.body).to include('Yes, remove it')
      expect(response.body).to include('No, do not remove it')
    end

    context 'when there are other businesses' do
      it 'deletes the business and redirects back to the summary page' do
        # ensure we have at least an additional business
        business = crime_application.businesses.create!(
          business_type: BusinessType::SELF_EMPLOYED,
          ownership_type: 'applicant'
        )

        expect do
          delete steps_income_businesses_path(
            id: crime_application, business_id: business
          )
        end.to change(Business, :count).by(-1)

        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(edit_steps_income_businesses_summary_path(crime_application))

        follow_redirect!

        assert_select 'div.govuk-notification-banner--success', 1 do
          assert_select 'h2', 'Success'
          assert_select 'p', 'You removed the business'
        end
      end
    end

    context 'when there are no more businesses' do
      it 'deletes the business and redirects to the business type page' do
        expect do
          delete steps_income_businesses_path(id: crime_application, business_id: business, subject: 'client')
        end.to change(Business, :count).by(-1)

        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(edit_steps_income_business_type_path)

        follow_redirect!

        assert_select 'div.govuk-notification-banner--success', 1 do
          assert_select 'h2', 'Success'
          assert_select 'p', 'You removed the business'
        end
      end
    end
  end
end
