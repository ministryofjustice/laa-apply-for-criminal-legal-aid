require 'rails_helper'

RSpec.describe Summary::Components::Property, type: :component do
  subject(:component) { render_inline(described_class.new(record:)) }

  let(:record) {
    instance_double(Property,
                    complete?: true,
                    property_owners: [property_owner],
                    include_partner?: client_has_partner,
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
  let(:client_has_partner) { false }
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

      is_home_address: 'yes',
      has_other_owners: 'yes',
    }
  end

  before { component }

  describe 'actions' do
    describe 'change link' do
      it 'show the correct change link' do
        expect(page).to have_link(
          'Change',
          href: '/applications/APP123/steps/capital/residential_property/PROPERTY123',
          exact_text: 'Change Residential property'
        )
      end
    end

    describe 'remove link' do
      it 'show the correct remove link' do
        expect(page).to have_link(
          'Remove',
          href: '/applications/APP123/steps/capital/properties/PROPERTY123/confirm_destroy',
          exact_text: 'Remove Residential property'
        )
      end
    end
  end

  describe 'answers' do
    it 'renders as summary list' do # rubocop:disable RSpec/ExampleLength
      expect(page).to have_summary_row(
        'Which type of property is it?',
        'other_house_type'
      )
      expect(page).to have_summary_row(
        'How many bedrooms are there?',
        '3',
      )
      expect(page).to have_summary_row(
        'How much is the property worth?',
        '£200,000.00',
      )
      expect(page).to have_summary_row(
        'How much is left to pay on the mortgage?',
        '£100,000.00',
      )
      expect(page).to have_summary_row(
        'What percentage of the property does your client own?',
        '70.54%',
      )
      expect(page).to have_summary_row(
        'Is the address of the property the same as your client’s home address?',
        'Yes',
      )
      expect(page).to have_summary_row(
        'Does anyone else own part of the property?',
        'Yes',
      )
    end

    context 'when client has no home address' do
      let(:is_home_address) { 'no' }

      it 'renders address in as summary list' do
        expect(page).to have_summary_row(
          'Is the address of the property the same as your client’s home address?',
          'No',
        )
        expect(page).to have_summary_row(
          'Address',
          'london TW7 United Kingdom',
        )
      end
    end

    context 'when client has home address' do
      let(:is_home_address) { 'yes' }

      it 'renders address in as summary list' do
        expect(page).to have_summary_row(
          'Is the address of the property the same as your client’s home address?',
          'Yes',
        )
      end
    end

    context 'when client has partner' do
      let(:client_has_partner) { true }

      it 'renders as summary list with partner percentage' do
        expect(page).to have_summary_row(
          'What percentage of the property does your client’s partner own?',
          '50.00%',
        )
      end
    end

    context 'when client has no partner' do
      let(:client_has_partner) { false }

      it 'renders as summary list without partner percentage', pending: 'to investigate why `not_to` is not working' do
        expect(page).not_to have_summary_row(
          'What percentage of the property does your client’s partner own?',
          '50.00%',
        )
      end
    end

    context 'when property has other owners' do
      let(:has_other_owners) { 'yes' }

      it 'renders as summary list with other owners' do
        expect(page).to have_summary_row(
          'Does anyone else own part of the property?',
          'Yes',
        )
        expect(page).to have_summary_row(
          'What is the name of the first other owner?',
          'Joe',
        )
        expect(page).to have_summary_row(
          'What is their relationship to your client?',
          'Friends',
        )
        expect(page).to have_summary_row(
          'What percentage of the property do they own?',
          '10.57%',
        )
      end

      context 'when other relationship' do
        let(:relationship) { 'other' }

        it 'renders as summary list with non-listed relationship' do
          expect(page).to have_summary_row(
            'What is their relationship to your client?',
            'xyz',
          )
        end
      end
    end

    context 'when property has no other owners' do
      let(:has_other_owners) { 'no' }

      it 'renders as summary list with other owners' do
        expect(page).to have_summary_row(
          'Does anyone else own part of the property?',
          'No',
        )
      end
    end

    context 'when property has other owners' do
      let(:has_other_owners) { 'yes' }

      it 'renders as summary list with other owners' do
        expect(page).to have_summary_row(
          'Does anyone else own part of the property?',
          'Yes',
        )
        expect(page).to have_summary_row(
          'What is the name of the [1st] other owner?',
          'Joe',
        )
        expect(page).to have_summary_row(
          'What is their relationship to your client?',
          'Friends',
        )
        expect(page).to have_summary_row(
          'What percentage of the property do they own?',
          '10%',
        )
      end

      context 'when custom relationship' do
        let(:relationship) { 'custom' }

        it 'renders as summary list with non-listed relationship' do
          expect(page).to have_summary_row(
            'What is their relationship to your client?',
            'xyz',
          )
        end
      end
    end

    context 'when property has no other owners' do
      let(:has_other_owners) { 'no' }

      it 'renders as summary list with other owners' do
        expect(page).to have_summary_row(
          'Does anyone else own part of the property?',
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
          'Which type of property is it?',
          'None'
        )
        expect(page).to have_summary_row(
          'How many bedrooms are there?',
          'None',
        )
        expect(page).to have_summary_row(
          'How much is the property worth?',
          'None',
        )
        expect(page).to have_summary_row(
          'How much is left to pay on the mortgage?',
          'None',
        )
        expect(page).to have_summary_row(
          'What percentage of the property does your client own?',
          'None',
        )

        expect(page).to have_summary_row(
          'Does anyone else own part of the property?',
          'None',
        )
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
