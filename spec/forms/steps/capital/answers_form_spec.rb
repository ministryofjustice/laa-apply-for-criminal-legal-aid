require 'rails_helper'

RSpec.describe Steps::Capital::AnswersForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application:
    }.merge(attributes)
  end

  let(:attributes) { {} }

  let(:crime_application) do
    instance_double(CrimeApplication)
  end

  describe '#persist!' do
    it { expect(form.persist!).to be_truthy }
  end
end
