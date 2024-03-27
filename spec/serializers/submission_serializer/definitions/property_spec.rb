require 'rails_helper'

RSpec.describe SubmissionSerializer::Definitions::Property do
  subject { described_class.generate(properties) }

  let(:properties) { [property1, property2] }
  let(:property1) do
    Property.new(
      property_type: 'residential',
      house_type: 'bungalow',
      other_house_type: nil,
      size_in_acres: 100,
      usage: 'usage details',
      bedrooms: 2,
      value: 300_000,
      outstanding_mortgage: 100_000,
      percentage_applicant_owned: 20.0,
      percentage_partner_owned: nil,
      is_home_address: 'yes',
      has_other_owners: 'no',
      address: { 'city' => 'London', 'postcode' => 'TW7' },
      property_owners: property_owners
    )
  end

  let(:property2) do
    Property.new(
      property_type: 'residential',
      house_type: 'other',
      other_house_type: 'other house type',
      size_in_acres: 200,
      usage: 'usage details',
      bedrooms: 2,
      value: 300_000,
      outstanding_mortgage: 100_000,
      percentage_applicant_owned: 70.0,
      percentage_partner_owned: 30.0,
      is_home_address: 'yes',
      has_other_owners: 'no',
      address: nil
    )
  end

  let(:property_owners) { [property_owner1, property_owner2] }
  let(:property_owner1) {
    PropertyOwner.new(
      name: 'owner1 name',
      relationship: 'friends',
      other_relationship: nil,
      percentage_owned: 10
    )
  }
  let(:property_owner2) {
    PropertyOwner.new(
      name: 'owner2 name',
      relationship: 'other',
      other_relationship: 'other name',
      percentage_owned: 90
    )
  }

  let(:json_output) do
    [
      {
        property_type: 'residential',
        house_type: 'bungalow',
        other_house_type: nil,
        size_in_acres: 100,
        usage: 'usage details',
        bedrooms: 2,
        value: 300_000,
        outstanding_mortgage: 100_000,
        percentage_applicant_owned: 20.0,
        percentage_partner_owned: nil,
        is_home_address: 'yes',
        has_other_owners: 'no',
        address: { 'city' => 'London', 'postcode' => 'TW7' },
        property_owners: [
          {
            name: 'owner1 name',
            relationship: 'friends',
            other_relationship: nil,
            percentage_owned: 10
          },
          {
            name: 'owner2 name',
            relationship: 'other',
            other_relationship: 'other name',
            percentage_owned: 90
          }
        ]
      },
      {
        property_type: 'residential',
        house_type: 'other',
        other_house_type: 'other house type',
        size_in_acres: 200,
        usage: 'usage details',
        bedrooms: 2,
        value: 300_000,
        outstanding_mortgage: 100_000,
        percentage_applicant_owned: 70.0,
        percentage_partner_owned: 30.0,
        is_home_address: 'yes',
        has_other_owners: 'no',
        address: nil,
        property_owners: []
      },
    ].as_json
  end

  describe '#generate' do
    it { expect(subject).to eq(json_output) }
  end
end
