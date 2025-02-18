require 'rails_helper'

RSpec.describe Summary::Components::Property, type: :component do
  subject(:component) { described_class.new(record:) }

  let(:record) {
    instance_double(Property,
                    complete?: true,
                    property_owners: [property_owner],
                    crime_application: crime_application,
                    address: nil, **attributes)
  }

  let(:property_owner) {
    instance_double(PropertyOwner,
                    name: 'Joe',
                    relationship: relationship,
                    other_relationship: 'xyz',
                    percentage_owned: 10.567)
  }
  let(:crime_application) { instance_double(CrimeApplication, id: 'APP123') }
  let(:relationship) { 'friends' }
  let(:property_type) { 'residential' }

  let(:attributes) do
    {
      id: 'PROPERTY123',
      crime_application_id: 'APP123',
      property_type: property_type,
      house_type: 'other',
      other_house_type: 'other_house_type',
      size_in_acres: nil,
      usage: nil,
      bedrooms: 3,
      value: 200_000,
      outstanding_mortgage: 100_000,
      percentage_applicant_owned: 70.538,
      percentage_partner_owned: 50,
      is_home_address: is_home_address,
      has_other_owners: has_other_owners,
      address: { 'city' => 'london', 'country' => 'United Kingdom', 'postcode' => 'TW7' },
    }
  end

  let(:is_home_address) { 'yes' }
  let(:has_other_owners) { 'yes' }

  before do
    render_summary_component(component)
  end

  describe 'actions' do
    context 'when show_record_actions set to false' do
      it 'show the "Edit" change link' do
        expect(page).to have_link(
          'Edit',
          href: '/applications/APP123/steps/capital/add-assets',
          exact_text: 'Edit Residential property'
        )
      end
    end

    context 'when show_record_actions true' do
      subject(:component) { described_class.new(record: record, show_record_actions: true) }

      describe 'change link' do
        it 'show the correct change link' do
          expect(page).to have_link(
            'Change',
            href: '/applications/APP123/steps/capital/residential-property/PROPERTY123',
            exact_text: 'Change Residential property'
          )
        end
      end

      describe 'remove link' do
        it 'show the correct remove link' do
          expect(page).to have_link(
            'Remove',
            href: '/applications/APP123/steps/capital/properties/PROPERTY123/confirm-destroy',
            exact_text: 'Remove Residential property'
          )
        end
      end
    end
  end

  describe 'answers' do
    it 'renders as summary list' do # rubocop:disable RSpec/ExampleLength
      expect(page).to have_summary_row(
        'Bedrooms',
        '3',
      )
      expect(page).to have_summary_row(
        'Property value',
        '£200,000',
      )
      expect(page).to have_summary_row(
        'Mortgage amount left',
        '£100,000',
      )
      expect(page).to have_summary_row(
        'Percentage client owns',
        '70.54%',
      )
      expect(page).to have_summary_row(
        'Address same as client’s home',
        'Yes',
      )
      expect(page).to have_summary_row(
        'Other owners',
        'Yes',
      )
    end

    context 'when client has no home address' do
      let(:is_home_address) { 'no' }

      it 'renders address in as summary list' do
        expect(page).to have_summary_row(
          'Address same as client’s home',
          'No',
        )

        within(page.first('.govuk-summary-card')) do
          expect(page).to have_summary_row(
            'Address',
            'london TW7 United Kingdom',
          )
        end
      end
    end

    context 'when client has home address' do
      let(:is_home_address) { 'yes' }

      it 'renders address in as summary list' do
        expect(page).to have_summary_row(
          'Address same as client’s home',
          'Yes',
        )
      end
    end

    describe 'summary list partner percentage' do
      context 'when partner percentage owned is present' do
        it 'renders as summary list with partner percentage' do
          expect(page).to have_summary_row('Percentage partner owns', '50%')
        end
      end
    end

    context 'when property has other owners' do
      let(:has_other_owners) { 'yes' }

      it 'renders as summary list with other owners' do
        expect(page).to have_summary_row(
          'Other owners',
          'Yes',
        )
        expect(page).to have_summary_row(
          'Name of other owner 1',
          'Joe',
        )
        expect(page).to have_summary_row(
          'Relationship to client',
          'Friends',
        )
        expect(page).to have_summary_row(
          'Percentage owner 1 owns',
          '10.57%',
        )
      end

      context 'when other relationship' do
        let(:relationship) { 'other' }

        it 'renders as summary list with non-listed relationship' do
          within('div.govuk-notification-banner__heading') do
            expect(page).to have_summary_row(
              'Relationship to client',
              'xyz',
            )
          end
        end
      end
    end

    context 'when property has no other owners' do
      let(:has_other_owners) { 'no' }

      it 'renders as summary list with other owners' do
        expect(page).to have_summary_row(
          'Other owners',
          'No',
        )
      end
    end

    context 'when answers are missing' do
      let(:attributes) do
        {
          id: 'PROPERTY123',
          crime_application_id: 'APP123',
          property_type: 'residential',
          house_type: nil,
          other_house_type: nil,
          size_in_acres: nil,
          usage: nil,
          bedrooms: nil,
          value: nil,
          outstanding_mortgage: nil,
          percentage_applicant_owned: nil,
          percentage_partner_owned: nil,
          is_home_address: nil,
          has_other_owners: nil,
        }
      end

      it 'renders as summary list with the correct absence_answer' do # rubocop:disable RSpec/ExampleLength
        expect(page).to have_summary_row(
          'Type of property',
          'Not provided',
        )
        expect(page).to have_summary_row(
          'Bedrooms',
          'Not provided',
        )
        expect(page).to have_summary_row(
          'Property value',
          '',
        )
        expect(page).to have_summary_row(
          'Mortgage amount left',
          '',
        )
        expect(page).to have_summary_row(
          'Other owners',
          '',
        )
      end

      context 'when partner percentage owned is not present' do
        it 'renders as summary list without partner percentage' do
          expect(page).not_to have_content('Percentage partner owns')
        end
      end
    end
  end

  describe 'card heading' do
    subject(:heading) do
      page.first('h2.govuk-summary-card__title').text
    end

    let(:attributes) { super().merge({ property_type: }) }

    context 'when residential' do
      let(:property_type) { 'residential' }

      it { is_expected.to eq 'Residential property' }
    end

    context 'when commercial' do
      let(:property_type) { 'commercial' }

      it { is_expected.to eq 'Commercial property' }
    end

    context 'when land' do
      let(:property_type) { 'land' }

      it { is_expected.to eq 'Land' }
    end
  end
end
