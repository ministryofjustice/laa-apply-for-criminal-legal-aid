require 'rails_helper'

RSpec.describe Steps::Capital::UsualPropertyDetailsForm do
  subject(:form) { described_class.new(crime_application:) }

  let(:applicant) { instance_double(Applicant, home_address:, residence_type:) }
  let(:home_address) { nil }
  let(:residence_type) { nil }
  let(:capital) { instance_double(Capital) }
  let(:properties) { class_double(Property) }
  let(:crime_application) { instance_double(CrimeApplication, applicant:, capital:, properties:) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:action, :blank, 'Select what you want to do next') }

    context 'when the action is an invalid option' do
      before { form.action = 'invalid_option' }

      it 'raises an inclusion error' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:action, :inclusion)).to be(true)
      end
    end
  end

  describe '#choices' do
    it { expect(form.choices).to eq(UsualPropertyDetailsCapitalAnswer.values) }
  end

  describe '#home_address' do
    let(:home_address) {
      HomeAddress.new(address_line_one: '1 Test Road', city: 'London', postcode: 'SW1 1RT',
                      country: 'United Kingdom')
    }

    it "returns client's formatted home address" do
      expect(form.home_address).to eq("1 Test Road\r\nLondon\r\nSW1 1RT\r\nUnited Kingdom")
    end
  end

  describe '#residence_ownership' do
    context 'when the residence is owned by the client' do
      let(:residence_type) { ResidenceType::APPLICANT_OWNED.to_s }

      it { expect(form.residence_ownership).to eq(ResidenceType::APPLICANT_OWNED.to_s) }
    end

    context 'when the residence is owned by the partner' do
      let(:residence_type) { ResidenceType::PARTNER_OWNED.to_s }

      it { expect(form.residence_ownership).to eq(ResidenceType::PARTNER_OWNED.to_s) }
    end

    context 'when the residence is joint owned by the client and the partner' do
      let(:residence_type) { ResidenceType::JOINT_OWNED.to_s }

      it { expect(form.residence_ownership).to eq(ResidenceType::JOINT_OWNED.to_s) }
    end
  end

  describe '#save' do
    let(:residential_property) { instance_double(Property, property_type: PropertyType::RESIDENTIAL.to_s) }

    before do
      allow(properties).to receive(:create!)
        .with(property_type: PropertyType::RESIDENTIAL.to_s).and_return(residential_property)
    end

    context 'when the action is `change_answer`' do
      before do
        form.action = 'change_answer'
        form.save
      end

      it { expect(properties).not_to have_received(:create!) }
      it { expect(form.residential_property).to be_nil }
    end

    context 'when the action is `provide_details`' do
      before do
        form.action = 'provide_details'
        form.save
      end

      it { expect(properties).to have_received(:create!).with(property_type: PropertyType::RESIDENTIAL.to_s) }
      it { expect(form.residential_property).to eq(residential_property) }
    end
  end
end
