require 'rails_helper'

RSpec.describe AddressFormDecorator do
  subject { described_class.new(form_object) }

  let(:form_object) { double('FormObject', record: address_record) }

  let(:address_record) { instance_double(Address, type: address_type, person: person_record, postcode: 'SW1A 2AA') }
  let(:person_record)  { instance_double(Person, type: person_type) }

  let(:address_type) { nil }
  let(:person_type)  { nil }

  # NOTE: we only really have for now `Applicant`, but as these decorator is built
  # to cope with multiple people types, we are testing it also for `Partner`

  describe '#page_title' do
    context 'for an applicant' do
      let(:person_type) { Applicant.to_s }

      context 'for a home address' do
        let(:address_type) { HomeAddress.to_s }

        it { expect(subject.page_title).to eq('.page_title.applicant.home_address') }
      end

      context 'for a correspondence address' do
        let(:address_type) { CorrespondenceAddress.to_s }

        it { expect(subject.page_title).to eq('.page_title.applicant.correspondence_address') }
      end
    end

    context 'for a partner' do
      let(:person_type) { Partner.to_s }

      context 'for a home address' do
        let(:address_type) { HomeAddress.to_s }

        it { expect(subject.page_title).to eq('.page_title.partner.home_address') }
      end

      context 'for a correspondence address' do
        let(:address_type) { CorrespondenceAddress.to_s }

        it { expect(subject.page_title).to eq('.page_title.partner.correspondence_address') }
      end
    end
  end

  describe '#heading' do
    context 'for an applicant' do
      let(:person_type) { Applicant.to_s }

      context 'for a home address' do
        let(:address_type) { HomeAddress.to_s }

        it { expect(subject.heading).to eq('.heading.applicant.home_address') }
      end

      context 'for a correspondence address' do
        let(:address_type) { CorrespondenceAddress.to_s }

        it { expect(subject.heading).to eq('.heading.applicant.correspondence_address') }
      end
    end

    context 'for a partner' do
      let(:person_type) { Partner.to_s }

      context 'for a home address' do
        let(:address_type) { HomeAddress.to_s }

        it { expect(subject.heading).to eq('.heading.partner.home_address') }
      end

      context 'for a correspondence address' do
        let(:address_type) { CorrespondenceAddress.to_s }

        it { expect(subject.heading).to eq('.heading.partner.correspondence_address') }
      end
    end
  end

  describe '#home_address?' do
    context 'for a home address' do
      let(:address_record) { HomeAddress.new }

      it { expect(subject.home_address?).to be(true) }
    end

    context 'for a correspondence address' do
      let(:address_record) { CorrespondenceAddress.new }

      it { expect(subject.home_address?).to be(false) }
    end
  end

  describe '#postcode' do
    it 'delegates method to the address record' do
      expect(address_record).to receive(:postcode)
      expect(subject.postcode).to eq('SW1A 2AA')
    end
  end

  describe '#addresses' do
    let(:form_object) { double('FormObject', addresses:) }

    context 'when there is only 1 address in the collection' do
      let(:addresses) { [Struct] }

      it 'contains an addresses count item' do
        expect(subject.addresses[0].lookup_id).to be_nil
        expect(subject.addresses[0].compact_address).to eq('1 address found')
      end
    end

    context 'when there are more than 1 addresses in the collection' do
      let(:addresses) { [Struct, Struct] }

      it 'contains an addresses count item' do
        expect(subject.addresses[0].lookup_id).to be_nil
        expect(subject.addresses[0].compact_address).to eq('2 addresses found')
      end
    end

    context 'when there are no addresses in the collection' do
      let(:addresses) { [] }

      it 'returns an empty array' do
        expect(subject.addresses).to eq([])
      end
    end
  end
end
