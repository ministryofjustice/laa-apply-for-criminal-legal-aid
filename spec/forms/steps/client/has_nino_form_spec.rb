require 'rails_helper'

RSpec.describe Steps::Client::HasNinoForm do
  subject { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application: crime_application,
      record: applicant_record,
    }.merge(
      form_attributes
    )
  end

  let(:form_attributes) do
    { nino: }
  end

  let(:crime_application) { instance_double(CrimeApplication, applicant: applicant_record) }
  let(:applicant_record) { Applicant.new }
  let(:not_means_tested) { false }

  before do
    allow(crime_application).to receive(:not_means_tested?).and_return(not_means_tested)
  end

  describe 'Has nino form' do
    let(:form_attributes) do
      { nino:, has_nino: }
    end

    let(:nino) { nil }
    let(:has_nino) { nil }

    describe '#choices' do
      it 'returns the possible choices' do
        expect(
          subject.choices
        ).to eq([YesNoAnswer::YES, YesNoAnswer::NO])
      end
    end

    describe '#save' do
      context 'when `has_nino` is not provided' do
        it 'returns false' do
          expect(subject.save).to be(false)
        end

        it 'has a validation error on the field' do
          expect(subject).not_to be_valid
          expect(subject.errors.of_kind?(:has_nino, :inclusion)).to be(true)
        end
      end

      context 'when `has_nino` is not valid' do
        let(:has_nino) { 'maybe' }

        it 'returns false' do
          expect(subject.save).to be(false)
        end

        it 'has a validation error on the field' do
          expect(subject).not_to be_valid
          expect(subject.errors.of_kind?(:has_nino, :inclusion)).to be(true)
        end
      end

      # rubocop:disable RSpec/NestedGroups
      context 'when `has_nino` is valid' do
        let(:has_nino) { YesNoAnswer::NO.to_s }

        it { is_expected.to be_valid }

        it 'passes validation' do
          expect(subject.errors.of_kind?(:has_nino, :invalid)).to be(false)
        end

        it_behaves_like 'a has-one-association form',
                        association_name: :applicant,
                        expected_attributes: {
                          'has_nino' => YesNoAnswer::NO,
                          'nino' => nil,
                          'benefit_type' => nil,
                          'last_jsa_appointment_date' => nil,
                          'passporting_benefit' => nil,
                          'will_enter_nino' => nil,
                          'has_benefit_evidence' => nil,
                        }

        context 'when `has_nino` answer is no' do
          let(:nino) { 'AB123456C' }

          context 'when a `nino` was previously recorded' do
            it { is_expected.to be_valid }

            it 'can make nino field nil if no longer required' do
              attributes = subject.send(:attributes_to_reset)
              expect(attributes['nino']).to be_nil
            end
          end
        end

        context 'when `has_nino` answer is yes' do
          let(:has_nino) { YesNoAnswer::YES.to_s }
          let(:nino) { 'AB123456C' }

          context 'when `nino` is blank' do
            let(:nino) { '' }

            it 'has a validation error on the field' do
              expect(subject).not_to be_valid
              expect(subject.errors.of_kind?(:nino, :blank)).to be(true)
            end
          end

          context 'when `nino` is invalid' do
            context 'with a random string' do
              let(:nino) { 'not a NINO' }

              it 'has a validation error on the field' do
                expect(subject).not_to be_valid
                expect(subject.errors.of_kind?(:nino, :invalid)).to be(true)
              end
            end

            context 'with an unused prefix' do
              let(:nino) { 'BG123456C' }

              it 'has a validation error on the field' do
                expect(subject).not_to be_valid
                expect(subject.errors.of_kind?(:nino, :invalid)).to be(true)
              end
            end
          end

          context 'when `nino` is valid' do
            context 'with spaces between numbers' do
              let(:nino) { 'AB 12 34 56 C' }

              it 'passes validation' do
                expect(subject).to be_valid
                expect(subject.errors.of_kind?(:nino, :invalid)).to be(false)
              end

              it 'removes spaces from input' do
                expect(subject.nino).to eq('AB123456C')
              end
            end

            context 'with trailing spaces' do
              let(:nino) { ' AB 1234 56C ' }

              it 'passed validation' do
                expect(subject).to be_valid
                expect(subject.errors.of_kind?(:nino, :invalid)).to be(false)
              end
            end
          end

          context 'when application is not means tested' do
            let(:not_means_tested) { true }

            context 'when `nino` is blank' do
              let(:nino) { '' }

              it 'does not have a validation error on the field' do
                expect(subject).to be_valid
                expect(subject.errors.of_kind?(:nino, :blank)).to be(false)
              end
            end

            context 'when `nino` a random string' do
              let(:nino) { 'not a NINO' }

              it 'has a validation error on the field' do
                expect(subject).not_to be_valid
                expect(subject.errors.of_kind?(:nino, :invalid)).to be(true)
              end
            end

            context 'when `nino` has an unused prefix' do
              let(:nino) { 'BG123456C' }

              it 'has a validation error on the field' do
                expect(subject).not_to be_valid
                expect(subject.errors.of_kind?(:nino, :invalid)).to be(true)
              end
            end
          end

          context 'when a `nino` was previously recorded' do
            it 'is valid' do
              expect(subject).to be_valid
              expect(
                subject.errors.of_kind?(
                  :nino,
                  :present
                )
              ).to be(false)
            end

            it 'cannot reset `nino` as it is relevant' do
              crime_application.applicant.update(has_nino: YesNoAnswer::YES.to_s)

              attributes = subject.send(:attributes_to_reset)
              expect(attributes['nino']).to eq(nino)
            end
          end

          context 'when a `nino` was not previously recorded' do
            it 'is also valid' do
              expect(subject).to be_valid
              expect(
                subject.errors.of_kind?(
                  :nino,
                  :present
                )
              ).to be(false)
            end
          end
        end
      end
      # rubocop:enable RSpec/NestedGroups
    end
  end
end
