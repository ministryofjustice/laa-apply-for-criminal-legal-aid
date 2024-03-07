require 'rails_helper'

RSpec.describe Steps::Case::HearingDetailsForm do
  subject { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application: crime_application,
      hearing_court_name: 'Cardiff Court',
      hearing_date: Date.tomorrow,
      is_first_court_hearing: is_first_court_hearing,
    }
  end

  let(:crime_application) { instance_double(CrimeApplication) }
  let(:is_first_court_hearing) { FirstHearingAnswer::YES.to_s }

  describe '#choices' do
    it 'returns the possible choices' do
      expect(
        subject.choices
      ).to eq([FirstHearingAnswer::YES, FirstHearingAnswer::NO, FirstHearingAnswer::NO_HEARING_YET])
    end
  end

  describe '#save' do
    context 'validations' do
      it { is_expected.to validate_presence_of(:hearing_court_name) }
      it { is_expected.to validate_presence_of(:hearing_date) }

      context 'when `is_first_court_hearing` is not provided' do
        let(:is_first_court_hearing) { '' }

        it 'has a validation error on the field' do
          expect(subject).not_to be_valid
          expect(subject.errors.of_kind?(:is_first_court_hearing, :inclusion)).to be(true)
        end
      end

      context 'when `is_first_court_hearing` is not valid' do
        let(:is_first_court_hearing) { 'foobar' }

        it 'has a validation error on the field' do
          expect(subject).not_to be_valid
          expect(subject.errors.of_kind?(:is_first_court_hearing, :inclusion)).to be(true)
        end
      end
    end

    context 'hearing_date' do
      it_behaves_like 'a multiparam date validation',
                      attribute_name: :hearing_date,
                      allow_future: true
    end

    # rubocop:disable Style/HashSyntax
    context 'when validations pass' do
      context 'when it is the first court hearing it resets dependent attributes' do
        it_behaves_like 'a has-one-association form',
                        association_name: :case,
                        expected_attributes: {
                          'hearing_court_name' => 'Cardiff Court',
                          'hearing_date' => Date.tomorrow,
                          'is_first_court_hearing' => FirstHearingAnswer::YES,
                          first_court_hearing_name: nil,
                        }
      end

      context 'when it is not the first court hearing' do
        let(:is_first_court_hearing) { FirstHearingAnswer::NO.to_s }

        it_behaves_like 'a has-one-association form',
                        association_name: :case,
                        expected_attributes: {
                          'hearing_court_name' => 'Cardiff Court',
                          'hearing_date' => Date.tomorrow,
                          'is_first_court_hearing' => FirstHearingAnswer::NO,
                        }
      end
    end
    # rubocop:enable Style/HashSyntax
  end
end
