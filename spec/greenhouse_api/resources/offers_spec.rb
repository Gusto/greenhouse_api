# typed: false
# frozen_string_literal: true

RSpec.describe GreenhouseApi::Resources::Offers do
  let(:client) { described_class.new(api_key) }
  let(:api_key) { 'testing-1234' }

  describe '#get_current_offer_for_application' do
    subject(:get_current_offer_for_application) { client.get_current_offer_for_application(application_id) }
    let(:application_id) { '89437968' }
    let(:request_params) { { http_method: :get, headers: client.headers, endpoint: "applications/#{application_id}/offers/current_offer" } }
    let(:response) { GreenhouseApi::Response.new(headers: '', body: '', status: '') }

    before do
      allow(client).to receive(:request).with(request_params)
      allow(client).to receive(:compose_response).and_return(response)
    end

    it 'calls request with offers endpoint' do
      expect(client).to receive(:request).with(request_params)
      subject
    end

    it 'composes response' do
      expect(client).to receive(:compose_response)
      subject
    end
  end
end
