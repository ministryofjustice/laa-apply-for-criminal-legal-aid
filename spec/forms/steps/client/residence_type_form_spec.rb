require 'rails_helper'

RSpec.describe Steps::Client::ResidenceTypeForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application:,
      record:,
      residence_type:,
      relationship_to_someone_else:
    }
  end

  let(:crime_application) { instance_double(CrimeApplication, applicant: record) }
  let(:record) { instance_double(Applicant, home_address:, relationship_to_someone_else:, residence_type:) }

  let(:residence_type) { ResidenceType::RENTED.to_s }
  let(:relationship_to_someone_else) { nil }
  let(:home_address) { instance_double HomeAddress }

  describe 'validations' do
    context 'when `residence_type` is blank' do
      let(:residence_type) { '' }

      it 'has is a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:residence_type, :inclusion)).to be(true)
      end
    end

    context 'when `residence_type` is invalid' do
      let(:residence_type) { 'invalid_type' }

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:residence_type, :inclusion)).to be(true)
      end
    end

    context 'when `residence_type` is valid' do
      it { is_expected.to be_valid }

      it 'passes validation' do
        expect(form.errors.of_kind?(:residence_type, :invalid)).to be(false)
      end

      it_behaves_like 'a has-one-association form',
                      association_name: :applicant,
                      expected_attributes: {
                        'residence_type' => ResidenceType::RENTED,
                        'relationship_to_someone_else' => nil
                      }

      context 'when `residence_type` answer is not someone_else' do
        context 'when a `relationship_to_someone_else` was previously recorded' do
          let(:relationship_to_someone_else) { 'A friend' }

          it { is_expected.to be_valid }

          it 'can make relationship_to_someone_else field nil if no longer required' do
            attributes = form.send(:attributes_to_reset)
            expect(attributes['relationship_to_someone_else']).to be_nil
          end
        end
      end

      context 'when `residence_type` answer is someone else' do
        context 'when a `relationship_to_someone_else` was previously recorded' do
          let(:residence_type) { ResidenceType::SOMEONE_ELSE.to_s }
          let(:relationship_to_someone_else) { 'A friend' }

          before do
            allow(record).to receive(:update).and_return true
          end

          it 'is valid' do
            expect(form).to be_valid
            expect(
              form.errors.of_kind?(
                :relationship_to_someone_else,
                :present
              )
            ).to be(false)
          end

          it 'cannot reset `relationship_to_someone_else` as it is relevant' do
            record.update(residence_type: ResidenceType::SOMEONE_ELSE.to_s)

            attributes = form.send(:attributes_to_reset)
            expect(attributes['relationship_to_someone_else']).to eq(relationship_to_someone_else)
          end
        end

        context 'when a `relationship_to_someone_else` was not previously recorded' do
          let(:residence_type) { ResidenceType::SOMEONE_ELSE.to_s }
          let(:relationship_to_someone_else) { 'A friend' }

          it 'is also valid' do
            expect(form).to be_valid
            expect(
              form.errors.of_kind?(
                :relationship_to_someone_else,
                :present
              )
            ).to be(false)
          end
        end
      end
    end
  end

  describe '#save' do
    before do
      allow(record).to receive(:residence_type).and_return(previous_residence_type)
    end

    context 'when the residence type has changed' do
      let(:previous_residence_type) { ResidenceType::PARENTS.to_s }

      it_behaves_like 'a has-one-association form',
                      association_name: :applicant,
                      expected_attributes: {
                        'residence_type' => ResidenceType::RENTED,
                        'relationship_to_someone_else' => nil
                      }
    end

    context 'when residence type is the same as in the persisted record' do
      let(:previous_residence_type) { ResidenceType::RENTED.to_s }

      it 'does not save the record but returns true' do
        expect(record).not_to receive(:update)
        expect(subject.save).to be(true)
      end
    end
  end

  context 'when residence type is none and a home address was previously recorded' do
    let(:residence_type) { ResidenceType::NONE }

    before do
      allow(record).to receive_messages(home_address?: true)
      allow(record).to receive(:update).with({ 'residence_type' => ResidenceType::NONE, 'relationship_to_someone_else' => nil }).and_return true
      allow(home_address).to receive(:destroy!)
      subject.save
    end

    it 'deletes existing home address' do
      expect(home_address).to have_received(:destroy!)
    end
  end
end
