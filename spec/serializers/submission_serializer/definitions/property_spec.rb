require 'rails_helper'

RSpec.describe SubmissionSerializer::Definitions::Property do
  subject { described_class.generate(savings) }

  let(:savings) { [property1, property2] }

  let(:property1) do
    instance_double(
      Property,
      {
        property_type: 'residential',
        house_type: 'bungalow',
        custom_house_type: nil,
        size_in_acres: 100,
        usage: 'usage details',
        bedrooms: 2,
        value_before_type_cast: 300_000,
        outstanding_mortgage_before_type_cast: 100_000,
        percentage_applicant_owned: 20.0,
        percentage_partner_owned: nil,
        is_home_address: 'yes',
        has_other_owners: 'no',
        address: { 'city' => 'London', 'postcode' => 'TW7' }
      }
    )
  end

  let(:property2) do
    instance_double(
      Property,
      property_type: 'residential',
      house_type: 'custom',
      custom_house_type: 'custom house type',
      size_in_acres: 200,
      usage: 'usage details',
      bedrooms: 2,
      value_before_type_cast: 300_000,
      outstanding_mortgage_before_type_cast: 100_000,
      percentage_applicant_owned: 70.0,
      percentage_partner_owned: 30.0,
      is_home_address: 'yes',
      has_other_owners: 'no',
      address: nil
    )
  end

  let(:json_output) do
    [
      {
        property_type: 'residential',
        house_type: 'bungalow',
        custom_house_type: nil,
        size_in_acres: 100,
        usage: 'usage details',
        bedrooms: 2,
        value: 300_000,
        outstanding_mortgage: 100_000,
        percentage_applicant_owned: 20.0,
        percentage_partner_owned: nil,
        is_home_address: 'yes',
        has_other_owners: 'no',
        address: { 'city' => 'London', 'postcode' => 'TW7' }
      },
      {
        property_type: 'residential',
        house_type: 'custom',
        custom_house_type: 'custom house type',
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
      },
    ].as_json
  end

  describe '#generate' do
    it { expect(subject).to eq(json_output) }
  end
end
