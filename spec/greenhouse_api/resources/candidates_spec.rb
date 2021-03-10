# typed: false
# frozen_string_literal: true

RSpec.describe GreenhouseApi::Resources::Candidates do
  let(:client) { described_class.new(api_key) }
  let(:api_key) { 'testing-1234' }

  describe '#list_all' do
    subject(:list_all) { client.list_all(params) }
    let(:params) { {} }
    let(:response) { GreenhouseApi::Response.new(headers: {}, body: 'body', status: 'status') }

    before do
      allow(client).to receive(:list_many).with('candidates', params).and_return(response)
    end

    it 'calls list_many with candidates endpoint' do
      expect(client).to receive(:list_many).with('candidates', params)
      subject
    end
  end
end
