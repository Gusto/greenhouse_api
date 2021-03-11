# typed: false
# frozen_string_literal: true

RSpec.describe GreenhouseApi::Resources::Users do
  let(:client) { described_class.new(api_key) }
  let(:api_key) { 'testing-1234' }
  let(:on_behalf_of_id) { '5435' }
  let(:user) { { user_id: '9803' } }
  let(:headers) { client.headers.merge('On-Behalf-Of' => on_behalf_of_id) }
  let(:response) { GreenhouseApi::Response.new(headers: {}, body: 'body', status: 'status') }

  shared_examples_for 'users endpoint request' do
    before do
      allow(client).to receive(:request).with(request_params)
      allow(client).to receive(:compose_response).and_return(response)
    end

    it 'calls request with the correct endpoint' do
      expect(client).to receive(:request).with(request_params)
      subject
    end

    it 'composes response' do
      expect(client).to receive(:compose_response)
      subject
    end
  end

  describe '#create_user' do
    subject(:create_user) { client.create_user(method_params) }
    let(:method_params) { body.merge(on_behalf_of_id: on_behalf_of_id) }
    let(:body) { { first_name: 'Kirby', last_name: 'Dirby', email: 'kirby@email.com' } }
    let(:request_params) {
      {
        http_method: :post,
        headers: headers,
        endpoint: "users",
        body: body.to_json
      }
    }

    it_behaves_like 'users endpoint request'
  end

  describe '#disable_user' do
    subject(:disable_user) { client.disable_user(user, on_behalf_of_id) }
    let(:request_params) {
      {
        http_method: :patch,
        headers: headers,
        endpoint: "users/disable",
        body: { user: user }.to_json,
        api_version: 'v2',
      }
    }

    it_behaves_like 'users endpoint request'
  end

  describe '#enable_user' do
    subject(:enable_user) { client.enable_user(user, on_behalf_of_id) }
    let(:request_params) {
      {
        http_method: :patch,
        headers: headers,
        endpoint: "users/enable",
        body: { user: user }.to_json,
        api_version: 'v2',
      }
    }

    it_behaves_like 'users endpoint request'
  end
end
