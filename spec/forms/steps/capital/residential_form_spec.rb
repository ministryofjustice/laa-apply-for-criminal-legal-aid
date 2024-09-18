require 'rails_helper'

RSpec.describe Steps::Capital::ResidentialForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) { { crime_application:, record: }.merge(attributes) }
  let(:attributes) { {} }
  let(:crime_application) { instance_double(CrimeApplication, applicant:, properties:) }
  let(:applicant) { instance_double(Applicant, home_address?: home_address?) }
  let(:record) do
    instance_double(Property, 'other_house_type=': nil, 'address=': nil)
  end
  let(:home_address?) { true }
  let(:include_partner?) { false }
  let(:properties) { class_double(Property, home_address:) }
  let(:home_address) { [] }

  before do
    allow(form).to receive(:include_partner_in_means_assessment?)
      .and_return(include_partner?)
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:house_type) }
    it { is_expected.to validate_presence_of(:bedrooms) }
    it { is_expected.to validate_presence_of(:value) }
    it { is_expected.to validate_presence_of(:outstanding_mortgage) }
    it { is_expected.to validate_presence_of(:percentage_applicant_owned) }
    it { is_expected.to validate_is_a(:has_other_owners, YesNoAnswer) }

    describe '#percentage_partner_owned' do
      context 'when partner included in means assessment' do
        let(:include_partner?) { true }

        it { is_expected.to validate_presence_of(:percentage_partner_owned) }
      end

      context 'when partner is not included in means assessment' do
        let(:include_partner?) { false }

        it { is_expected.not_to validate_presence_of(:percentage_partner_owned) }
      end
    end

    describe '#other_house_type' do
      before { allow(subject).to receive(:other_house_type?).and_return(other_house_type_selected) }

      context 'when other_house_type is selected' do
        let(:other_house_type_selected) { true }

        it { is_expected.to validate_presence_of(:other_house_type) }
      end

      context 'when other_house_type is not selected' do
        let(:other_house_type_selected) { false }

        it { is_expected.not_to validate_presence_of(:other_house_type) }
      end
    end

    describe '#is_home_address' do
      before do
        allow(record).to receive(:id).and_return('123')
      end

      context 'when the home address question is displayed' do
        context 'when the applicant has a home address and home address property is unknown' do
          let(:home_address?) { true }
          let(:home_address) { [] }

          it { is_expected.to validate_is_a(:is_home_address, YesNoAnswer) }
        end

        context 'when the current property is the home address' do
          let(:home_address) { [instance_double(Property, id: '123')] }

          it { is_expected.to validate_is_a(:is_home_address, YesNoAnswer) }
        end
      end

      context 'when the home address question is not displayed' do
        context 'when the current property is not the home address' do
          let(:home_address) { [instance_double(Property, id: '456')] }

          it { is_expected.not_to validate_is_a(:is_home_address, YesNoAnswer) }
        end
      end
    end
  end

  describe '#save' do
    let(:required_attributes) do
      {
        house_type: 'bungalow',
        other_house_type: nil,
        bedrooms: 2,
        value: 170_000,
        outstanding_mortgage: 100_000,
        percentage_applicant_owned: 90,
        is_home_address: 'yes',
        has_other_owners: 'yes',
      }
    end

    context 'when house type is not listed' do
      context 'with valid attributes' do
        let(:attributes) { required_attributes.merge(house_type: 'other', other_house_type: 'other house type') }

        it 'updates the record' do
          expect(record).to receive(:update).and_return(true)
          expect(subject.save).to be(true)
        end
      end

      context 'with invalid attributes' do
        let(:attributes) { required_attributes.merge(house_type: 'other') }

        it 'updates the record' do
          expect(record).not_to receive(:update)
          expect(subject.save).to be(false)
        end
      end
    end

    context 'when client has no partner' do
      let(:include_partner?) { false }

      context 'for valid details' do
        let(:attributes) { required_attributes }

        it 'updates the record' do
          expect(record).to receive(:update).and_return(true)

          expect(subject.save).to be(true)
        end
      end

      context 'percentage_applicant_owned validation' do
        context 'when percentage applicant owned is 0' do
          let(:attributes) { required_attributes.merge(percentage_applicant_owned: 0) }

          it 'adds an error' do
            expect(subject.save).to be(false)
            expect(subject.errors.of_kind?(:percentage_applicant_owned, :greater_than)).to be(true)
          end
        end

        context 'when percentage applicant owned greater than 100' do
          let(:attributes) { required_attributes.merge(percentage_applicant_owned: 101) }

          it 'adds an error' do
            expect(subject.save).to be(false)
            expect(subject.errors.of_kind?(:percentage_applicant_owned, :less_than_or_equal_to)).to be(true)
          end
        end
      end

      # context 'home address validation' do
      #   let(:attributes) { required_attributes }
      #
      #   context 'when home address has already been set' do
      #     before do
      #       allow(record).to receive(:id).and_return('123')
      #     end
      #
      #     context 'and the current property is not the home address' do # rubocop:disable RSpec/NestedGroups
      #       let(:home_address) { [instance_double(Property, id: '456')] }
      #
      #       it 'adds an error' do
      #         expect(subject.save).to be(false)
      #         expect(subject.errors.of_kind?(:is_home_address, :invalid)).to be(true)
      #       end
      #     end
      #
      #     context 'and the current property is the home address' do # rubocop:disable RSpec/NestedGroups
      #       let(:home_address) { [instance_double(Property, id: '123')] }
      #
      #       it 'updates the record' do
      #         expect(record).to receive(:update).and_return(true)
      #         expect(subject.save).to be(true)
      #       end
      #     end
      #   end
      #
      #   context 'when home address has not been set' do
      #     let(:home_address) { [] }
      #
      #     before do
      #       allow(record).to receive(:id).and_return('123')
      #     end
      #
      #     it 'updates the record' do
      #       expect(record).to receive(:update).and_return(true)
      #       expect(subject.save).to be(true)
      #     end
      #   end
      # end
    end

    context 'when client has a partner' do
      let(:include_partner?) { true }

      context 'for invalid details' do
        let(:attributes) { required_attributes }

        it 'updates the record' do
          expect(record).not_to receive(:update)

          expect(subject.save).to be(false)
        end
      end

      context 'for valid details' do
        let(:attributes) { required_attributes.merge(percentage_partner_owned: 5) }

        it 'updates the record' do
          expect(record).to receive(:update).and_return(true)

          expect(subject.save).to be(true)
        end
      end

      context 'percentage_applicant_owned validation' do
        context 'when percentage applicant owned is less than 0' do
          let(:attributes) { required_attributes.merge(percentage_applicant_owned: -1) }

          it 'adds an error' do
            expect(subject.save).to be(false)
            expect(subject.errors.of_kind?(:percentage_applicant_owned, :greater_than_or_equal_to)).to be(true)
          end
        end

        context 'when percentage applicant owned is 0' do
          let(:attributes) { required_attributes.merge(percentage_applicant_owned: 0, percentage_partner_owned: 10) }

          it 'updates the record' do
            expect(record).to receive(:update).and_return(true)

            expect(subject.save).to be(true)
          end
        end

        context 'when percentage applicant owned greater than 100' do
          let(:attributes) { required_attributes.merge(percentage_applicant_owned: 101) }

          it 'adds an error' do
            expect(subject.save).to be(false)
            expect(subject.errors.of_kind?(:percentage_applicant_owned, :less_than_or_equal_to)).to be(true)
          end
        end
      end
    end

    describe '#house_types' do
      it 'returns the possible choices' do
        expect(subject.house_types.map(&:to_s)).to eq(
          %w[bungalow detached flat_or_maisonette semidetached terraced]
        )
      end
    end
  end
end
