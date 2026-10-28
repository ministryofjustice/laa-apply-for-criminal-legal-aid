require 'rails_helper'

RSpec.describe JSON::Validator do
  describe '.parse' do
    it 'parses objects and top-level scalar values' do
      expect(described_class.parse('{"value":42}')).to eq('value' => 42)
      expect(described_class.parse('42')).to eq(42)
      expect(described_class.parse('null')).to be_nil
    end

    it 'reports malformed JSON as a schema parser error' do
      expect { described_class.parse('{') }.to raise_error(JSON::Schema::JsonParseError)
    end

    it 'rejects duplicate keys as a schema parser error' do
      expect { described_class.parse('{"value":1,"value":2}') }
        .to raise_error(JSON::Schema::JsonParseError, /duplicate key/)
    end
  end
end
