RSpec.shared_examples 'a has-one-association form' do |options|
  let(:association_name) { options[:association_name] }
  let(:expected_attributes) { options[:expected_attributes] }
  let(:build_method_name) { "build_#{association_name}".to_sym }

  let(:association_double) { double(association_name) }

  context 'for valid details' do
    context 'when record does not exist' do
      before do
        allow(crime_application).to receive(association_name).and_return(nil)
      end

      it 'creates the record if it does not exist' do
        expect(crime_application).to receive(build_method_name).and_return(association_double)

        expect(association_double).to receive(:update).with(
          expected_attributes
        ).and_return(true)

        expect(subject.save).to be(true)
      end
    end

    context 'when record already exists' do
      before do
        allow(crime_application).to receive(association_name).and_return(association_double)
      end

      it 'updates the record if it already exists' do
        expect(crime_application).not_to receive(build_method_name)

        expect(association_double).to receive(:update).with(
          expected_attributes
        ).and_return(true)

        expect(subject.save).to be(true)
      end
    end
  end
end
