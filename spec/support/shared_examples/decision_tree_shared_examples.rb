RSpec.shared_examples 'a decision tree' do
  context 'when the step_name is not recognised' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :foobar }

    it 'raises an error' do
      expect {
        subject.destination
      }.to raise_error(
        Decisions::BaseDecisionTree::InvalidStep, "Invalid step 'foobar'"
      )
    end
  end
end
