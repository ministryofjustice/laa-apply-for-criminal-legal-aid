# spec/middleware/session_cookie_overflow_logger_spec.rb
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SessionCookieOverflowLogger do
  subject(:middleware) { described_class.new(app, logger:) }

  let(:logger) { instance_spy(Logger) }
  let(:session) { { 'large_key' => 'x' * 100, 'small_key' => 'abc' } }

  let(:env) do
    {
      'rack.session' => session,
      'PATH_INFO' => '/providers/auth/entra',
      'REQUEST_METHOD' => 'POST',
      'action_dispatch.request_id' => 'request-id'
    }
  end

  describe '#call' do
    context 'when the downstream app succeeds' do
      let(:response) { [200, {}, ['OK']] }
      let(:app) { ->(_env) { response } }

      it 'returns the downstream response' do
        expect(middleware.call(env)).to eq(response)
      end

      it 'does not log anything' do
        middleware.call(env)

        expect(logger).not_to have_received(:error)
      end
    end

    context 'when the downstream app raises CookieOverflow' do
      let(:app) do
        lambda do |_env|
          raise ActionDispatch::Cookies::CookieOverflow,
                'session cookie overflow'
        end
      end

      it 'logs session diagnostics and re-raises the exception' do # rubocop:disable RSpec/ExampleLength,RSpec/MultipleExpectations
        expect do
          middleware.call(env)
        end.to raise_error(ActionDispatch::Cookies::CookieOverflow)

        expect(logger).to have_received(:error) do |json|
          payload = JSON.parse(json)

          expect(payload['event']).to eq('session_cookie_overflow')
          expect(payload['exception']).to eq('ActionDispatch::Cookies::CookieOverflow')
          expect(payload['request_path']).to eq('/providers/auth/entra')
          expect(payload['request_method']).to eq('POST')
          expect(payload['request_id']).to eq('request-id')
          expect(payload['session_key_count']).to eq(2)

          expect(payload['largest_session_keys']).to include(
            'large_key',
            'small_key'
          )

          expect(
            payload['largest_session_keys']['large_key']['estimated_bytes']
          ).to be >
               payload['largest_session_keys']['small_key']['estimated_bytes']

          expect(
            payload['largest_session_keys']['large_key']['class']
          ).to eq('String')
        end
      end
    end

    context 'when estimating the size raises an error' do
      let(:unmarshallable) do
        Class.new do
          def marshal_dump
            raise TypeError
          end

          def to_s
            'fallback'
          end
        end.new
      end

      let(:session) do
        { 'bad_key' => unmarshallable }
      end

      let(:app) do
        lambda do |_env|
          raise ActionDispatch::Cookies::CookieOverflow,
                'session cookie overflow'
        end
      end

      it 'falls back to using the string representation size' do
        expect do
          middleware.call(env)
        end.to raise_error(ActionDispatch::Cookies::CookieOverflow)

        expect(logger).to have_received(:error)
      end
    end
  end
end
