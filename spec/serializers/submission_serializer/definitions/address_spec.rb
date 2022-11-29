require 'rails_helper'

RSpec.describe SubmissionSerializer::Definitions::Address do
  subject { described_class }

  let(:address) do
    HomeAddress.new(
      address_line_one: 'Test',
      address_line_two: 'Home',
      city: 'City',
      country: 'Country',
      postcode: 'A11 1XX',
    )
  end

  let(:json_output) do
    {
      address_line_one: 'Test',
      address_line_two: 'Home',
      city: 'City',
      country: 'Country',
      postcode: 'A11 1XX',
    }.as_json
  end

  describe '#generate' do
    it { expect(subject.generate(address)).to eq(json_output) }
  end
end
