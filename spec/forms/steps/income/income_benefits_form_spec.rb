require 'rails_helper'

RSpec.describe Steps::Income::IncomeBenefitsForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application: crime_application,
      types: allowed_types,
    }
  end

  let(:crime_application) { CrimeApplication.new(case: case_record) }
  let(:case_record) { Case.new }

  let(:allowed_types) do
    %w[maintenance private_pension state_pension interest_investment student_loan_grant
       board_from_family rent financial_support_with_access from_friends_relatives other]
  end

  let(:fieldset_form_class) { Steps::Income::IncomeBenefitFieldsetForm }

  describe 'types' do
    let(:example_attribute_data) do
      { 'amount_in_pounds' => 23.30, 'frequency' => 'week' }
    end

    context 'when defined as an attribute' do
      it 'responds with a fieldset form', :aggregate_failures do
        allowed_types.each do |type|
          subject.public_send("#{type}=", example_attribute_data)
          response = subject.public_send(type)

          expect(response).to be_a fieldset_form_class
          expect(response.amount).to eq 2330
          expect(response.payment_type).to eq type
          expect(response.frequency).to eq 'week'
          expect(response.details).to be_nil
        end
      end

      it 'persists the fieldset form when attribute is initially set' do
        expect do
          allowed_types.each { |type| subject.public_send("#{type}=", example_attribute_data) }
        end.to change { subject.crime_application.income_benefits.size }.by(allowed_types.size)
      end

      it 'replaces the persisted fieldset form when attribute is reset' do # rubocop:disable RSpec/MultipleExpectations, RSpec/ExampleLength
        subject.other = {
          'amount_in_pounds' => 103.26,
          'frequency' => 'month',
          'details' => 'Earned some cash selling furniture'
        }
        record = subject.crime_application.income_benefits.find_by(payment_type: 'other')
        expect(subject.crime_application.income_benefits.size).to eq 1
        expect(record.amount).to eq 10_326
        expect(record.frequency).to eq 'month'
        expect(record.details).to eq 'Earned some cash selling furniture'

        subject.other = {
          'amount_in_pounds' => 8982.10,
          'frequency' => 'annual'
        }
        record = subject.crime_application.income_benefits.find_by(payment_type: 'other')
        expect(subject.crime_application.income_benefits.size).to eq 1
        expect(record.amount).to eq 898_210
        expect(record.frequency).to eq 'annual'
        expect(record.details).to be_nil
      end
    end
  end

  describe '#ordered_payment_types' do
    it 'outputs payment types in the correct order' do
      expect(subject.ordered_payment_types).to match_array(allowed_types)
    end
  end

  describe 'checked?' do
    context 'when persisted record exists' do
      before do
        # Persist
        subject.other = { 'amount_in_pounds' => 105.50, 'frequency' => 'four_weeks' }
      end

      it 'returns true' do
        expect(subject.checked?('other')).to be true
      end
    end

    # When user selects a payment type but the data is invalid e.g.
    # missing amount, missing frequency, assume the type itself was 'checked'
    context 'record was submitted but not persisted' do
      subject(:form) do
        described_class.new(
          crime_application: crime_application,
          types: %w[rent] # Submitted/initialising payment values
        )
      end

      it 'returns true for submitted value' do
        expect(subject.checked?('rent')).to be true
      end

      it 'returns false for unsubmitted value' do
        expect(subject.checked?('other')).to be false
      end
    end

    context 'with invalid type' do
      it 'throws exception' do
        expect { subject.checked?('bad type') }.to raise_error(NoMethodError, /undefined method `bad type'/)
      end
    end
  end

  describe '#save' do
    context 'with form submission' do
      subject do
        described_class.new(
          crime_application: crime_application,
          types: form_data.dig('steps_income_income_benefits_form', 'types'),
          income_benefits: form_data.dig('steps_income_income_benefits_form', 'income_benefits'),
        )
      end

      before do
        allowed_types.each do |type|
          subject.public_send("#{type}=", form_data.dig('steps_income_income_benefits_form', type))
        end

        subject.valid?
      end

      context 'with valid data' do
        let(:form_data) do
          {
            'steps_income_income_benefits_form' => {
              'income_benefits' => [''], # Rails nested attributes field
              'types' => %w[child jsa other], # Selected payment checkboxes

              'child' =>  { 'amount_in_pounds' => '56.12', 'frequency' => 'week' }, # Data for selected payment
              'working_or_child_tax_credit' => { 'amount_in_pounds' => '', 'frequency' => '' },
              'incapacity' => { 'amount_in_pounds' => '', 'frequency' => '' },
              'industrial_injuries_disablement' => { 'amount_in_pounds' => '', 'frequency' => '' },
              'jsa' => { 'amount_in_pounds' => '3.00', 'frequency' => 'annual' },
              'other' => { 'amount_in_pounds' => '44', 'frequency' => 'week', 'details' => 'Side hustle' },
            }
          }
        end

        it 'is valid' do
          expect(subject).to be_valid
        end
      end

      context 'with invalid data' do
        let(:form_data) do
          {
            'steps_income_income_benefits_form' => {
              'income_benefits' => [''],
              'types' => %w[child jsa other],

              'child' =>  { 'amount_in_pounds' => '', 'frequency' => 'every week' },
              'working_or_child_tax_credit' => { 'amount_in_pounds' => '', 'frequency' => '' },
              'incapacity' => { 'amount_in_pounds' => '', 'frequency' => '' },
              'industrial_injuries_disablement' => { 'amount_in_pounds' => '', 'frequency' => '' },
              'jsa' => { 'amount_in_pounds' => '3.00', 'frequency' => 'annual', 'details' => 'How?' },
              'other' => { 'amount_in_pounds' => '44', 'frequency' => 'week', 'details' => 'Side hustle' },
            }
          }
        end

        it 'is invalid' do
          expect(subject).not_to be_valid
        end

        it 'has error messages' do
          expect(subject.errors.of_kind?('child-amount_in_pounds', :greater_than)).to be(true)
          expect(subject.errors.of_kind?('child-frequency', :inclusion)).to be(true)
          expect(subject.errors.of_kind?('jsa-details', :invalid)).to be(true)

          # Error attributes should respond
          expect(subject.send(:'maintenance-amount_in_pounds')).to eq '0.00'
        end
      end
    end

    context 'when `none` type' do
      subject(:form) do
        described_class.new(
          crime_application: crime_application,
          types: %w[none]
        )
      end

      before do
        subject.valid?
      end

      it 'saves nothing' do
        expect(subject.crime_application.income_benefits.size).to eq 0

        # Always true because child records must already be persisted beforehand.
        # The `.save` is called as part of the BaseFormObject lifecycle
        expect(subject.save).to be true

        expect(subject.errors.size).to eq 0
      end
    end

    context 'when no attributes are invoked' do
      subject(:form) do
        described_class.new(
          crime_application: crime_application,
          types: %w[]
        )
      end

      it 'saves nothing' do
        expect(subject.crime_application.income_benefits.size).to eq 0
        expect(subject.save).to be true # Always true
        expect(subject.errors.size).to eq 0
      end
    end
  end
end
