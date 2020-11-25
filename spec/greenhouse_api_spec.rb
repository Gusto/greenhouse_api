# frozen_string_literal: true

RSpec.describe GreenhouseApi::Client do
  let(:client) { described_class.new(api_key) }
  let(:api_key) { 'testing-1234' }

  describe '#list_candidates' do
    subject(:list_candidates) { client.list_candidates(params) }
    let(:params) { {} }

    it 'calls list_many with candidates endpoint' do
      expect(client).to receive(:list_many).with('candidates', params)
      subject
    end
  end
end
