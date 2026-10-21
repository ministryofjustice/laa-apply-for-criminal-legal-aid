require 'rails_helper'

RSpec.describe JsonSchemaParser do
  describe 'JSON::Validator.parse' do
    it 'parses objects and top-level scalar values' do
      expect(JSON::Validator.parse('{"value":42}')).to eq('value' => 42)
      expect(JSON::Validator.parse('42')).to eq(42)
      expect(JSON::Validator.parse('null')).to be_nil
    end

    it 'reports malformed JSON as a schema parser error' do
      expect { JSON::Validator.parse('{') }.to raise_error(JSON::Schema::JsonParseError)
    end

    it 'rejects duplicate keys as a schema parser error' do
      expect { JSON::Validator.parse('{"value":1,"value":2}') }
        .to raise_error(JSON::Schema::JsonParseError, /duplicate key/)
    end
  end
end
