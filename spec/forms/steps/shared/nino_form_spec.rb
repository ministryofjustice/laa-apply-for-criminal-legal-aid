require 'rails_helper'

RSpec.describe Steps::Shared::NinoForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application:,
      record:,
      nino:,
      arc:,
      has_nino:,
      has_arc:,
      has_arc_or_nino:,
    }
  end

  let(:crime_application) { instance_double(CrimeApplication, applicant: record) }
  let(:record) { Applicant.new }

  let(:not_means_tested) { false }
  let(:nino) { nil }
  let(:arc) { nil }
  let(:has_nino) { nil }
  let(:has_arc) { nil }
  let(:has_arc_or_nino) { nil }

  before do
    allow(crime_application).to receive(:not_means_tested?).and_return(not_means_tested)
  end

  describe '#form_subject' do
    subject(:form_subject) { form.form_subject }

    context 'when record is Applicant' do
      let(:record) { Applicant.new }

      it { is_expected.to be_applicant }
    end

    context 'when record is Partner' do
      let(:record) { Partner.new }

      it { is_expected.to be_partner }
    end
  end

  describe '#validations' do
    context 'when `has_arc_or_nino` is not provided' do
      it 'returns false' do
        expect(form.save).to be(false)
      end

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:has_arc_or_nino, :blank)).to be(true)
      end
    end

    context 'when `has_arc_or_nino` is invalid' do
      let(:has_arc_or_nino) { 'maybe' }

      it 'returns false' do
        expect(form.save).to be(false)
      end

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:has_arc_or_nino, :blank)).to be(true)
      end
    end

    context 'when `has_nino` is yes' do
      let(:has_arc_or_nino) { 'yes' }
      let(:has_nino) { YesNoAnswer::YES.to_s }

      context 'when `nino` is blank' do
        let(:nino) { '' }

        it 'has a validation error on the field' do
          expect(form).not_to be_valid
          expect(form.errors.of_kind?(:nino, :blank)).to be(true)
        end
      end

      context 'with nino is a random string' do
        let(:nino) { 'not a NINO' }

        it 'has a validation error on the field' do
          expect(form).not_to be_valid
          expect(form.errors.of_kind?(:nino, :invalid)).to be(true)
        end
      end

      context 'when nino has an invalid prefix' do
        let(:nino) { 'BG123456C' }

        it 'has a validation error on the field' do
          expect(form).not_to be_valid
          expect(form.errors.of_kind?(:nino, :invalid)).to be(true)
        end
      end

      context 'when `nino` is valid' do
        context 'with spaces between numbers' do
          let(:nino) { 'AB 12 34 56 C' }

          it 'passes validation' do
            expect(form).to be_valid
            expect(form.errors.of_kind?(:nino, :invalid)).to be(false)
          end

          it 'removes spaces from input' do
            expect(form.nino).to eq('AB123456C')
          end
        end

        context 'with trailing spaces' do
          let(:nino) { ' AB 1234 56C ' }

          it 'passed validation' do
            expect(form).to be_valid
            expect(form.errors.of_kind?(:nino, :invalid)).to be(false)
          end
        end
      end

      context 'when application is not means tested' do
        let(:not_means_tested) { true }

        context 'when `nino` is blank' do
          let(:nino) { '' }

          it 'does not have a validation error on the field' do
            expect(form).to be_valid
            expect(form.errors.of_kind?(:nino, :blank)).to be(false)
          end
        end

        context 'when `nino` a random string' do
          let(:nino) { 'not a NINO' }

          it 'has a validation error on the field' do
            expect(form).not_to be_valid
            expect(form.errors.of_kind?(:nino, :invalid)).to be(true)
          end
        end

        context 'when `nino` has an invalid prefix' do
          let(:nino) { 'BG123456C' }

          it 'has a validation error on the field' do
            expect(form).not_to be_valid
            expect(form.errors.of_kind?(:nino, :invalid)).to be(true)
          end
        end
      end
    end

    context 'when `has_arc_or_nino` is arc' do
      let(:has_arc_or_nino) { 'arc' }

      context 'when `arc` is blank' do
        let(:arc) { '' }

        it 'has a validation error on the field' do
          expect(form).not_to be_valid
          expect(form.errors.of_kind?(:arc, :blank)).to be(true)
        end
      end

      context 'when `arc` is invalid' do
        let(:arc) { 'abcdefg' }

        it 'has a validation error on the field' do
          expect(form).not_to be_valid
          expect(form.errors.of_kind?(:arc, :invalid)).to be(true)
        end
      end

      context 'when `arc` is valid' do
        let(:arc) { 'ABC12/345678/A' }

        it 'passes validation' do
          expect(form).to be_valid
          expect(form.errors.of_kind?(:arc, :invalid)).to be(false)
        end
      end
    end
  end

  describe '#save' do
    context 'when `has_arc_or_nino` is valid and has_nino is no' do
      let(:has_arc_or_nino) { 'no' }
      let(:has_nino) { YesNoAnswer::NO.to_s }

      it { is_expected.to be_valid }

      it 'passes validation' do
        expect(form.errors.of_kind?(:has_arc_or_nino, :blank)).to be(false)
      end

      it 'saves `has_nino` value and returns true' do
        expect(record).to receive(:update).with({
                                                  'has_nino' => YesNoAnswer::NO,
                                                  'nino' => nil,
                                                  'arc' => nil,
                                                  'has_arc' => YesNoAnswer::NO,
                                                  'benefit_type' => nil,
                                                  'last_jsa_appointment_date' => nil,
                                                  'benefit_check_result' => nil,
                                                  'will_enter_nino' => nil,
                                                  'has_benefit_evidence' => nil,
                                                  'confirm_details' => nil,
                                                  'confirm_dwp_result' => nil,
                                                }).and_return(true)
        expect(form.save).to be(true)
      end

      context 'when `has_nino` answer is no and a `nino` was previously recorded' do
        let(:has_arc_or_nino) { 'no' }
        let(:nino) { 'AB123456C' }

        it { is_expected.to be_valid }

        it 'can make nino field nil if no longer required' do
          attributes = form.send(:attributes_to_reset)
          expect(attributes['nino']).to be_nil
        end
      end
    end

    context 'when has_nino is yes and nino is provided' do
      before do
        allow(record).to receive_messages(has_nino: YesNoAnswer::YES.to_s, nino: 'AB123456C',
                                          has_arc: YesNoAnswer::NO.to_s)
      end

      let(:has_arc_or_nino) { 'yes' }
      let(:has_nino) { YesNoAnswer::YES }

      context 'when nino is unchanged' do
        let(:nino) { 'AB123456C' }

        it 'does not save the record but returns true' do
          expect(record).not_to receive(:update)
          expect(form.save).to be(true)
        end
      end

      context 'when nino is changed' do
        let(:nino) { 'PM123456D' }

        it 'saves `nino` value and returns true' do
          expect(record).to receive(:update).with({
                                                    'has_nino' => YesNoAnswer::YES,
                                                    'nino' => 'PM123456D',
                                                    'arc' => nil,
                                                    'has_arc' => YesNoAnswer::NO,
                                                    'benefit_type' => nil,
                                                    'last_jsa_appointment_date' => nil,
                                                    'benefit_check_result' => nil,
                                                    'will_enter_nino' => nil,
                                                    'has_benefit_evidence' => nil,
                                                    'confirm_details' => nil,
                                                    'confirm_dwp_result' => nil,
                                                  }).and_return(true)
          expect(form.save).to be(true)
        end
      end
    end

    context 'when has_arc is yes and arc is provided' do
      before do
        allow(record).to receive_messages(has_arc: YesNoAnswer::YES.to_s, arc: 'ABC12/345678/A')
      end

      let(:has_arc_or_nino) { 'arc' }
      let(:has_arc) { YesNoAnswer::YES }

      context 'when has arc and arc number is unchanged' do
        let(:arc) { 'ABC12/345678/A' }

        it 'does not save the record but returns true' do
          expect(record).not_to receive(:update)
          expect(form.save).to be(true)
        end
      end

      context 'when has arc number is changed' do
        let(:arc) { 'LMC12/345678/B' }

        it 'saves `arc` value and returns true' do
          expect(record).to receive(:update).with({
                                                    'has_nino' => nil,
                                                    'nino' => nil,
                                                    'arc' => 'LMC12/345678/B',
                                                    'has_arc' => YesNoAnswer::YES,
                                                    'benefit_type' => nil,
                                                    'last_jsa_appointment_date' => nil,
                                                    'benefit_check_result' => nil,
                                                    'will_enter_nino' => nil,
                                                    'has_benefit_evidence' => nil,
                                                    'confirm_details' => nil,
                                                    'confirm_dwp_result' => nil,
                                                  }).and_return(true)
          expect(form.save).to be(true)
        end
      end
    end
  end
end
