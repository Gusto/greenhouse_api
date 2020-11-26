# frozen_string_literal: true

RSpec.describe GreenhouseApi::Client do
  let(:client) { described_class.new(api_key) }
  let(:api_key) { 'testing-1234' }

  describe '#list_many' do
    subject(:list_many) { client.list_many('candidates', params) }

    context 'when there is a limit' do
      let(:params) { { limit: 1 } }

      it 'fetches candidate data' do
        VCR.use_cassette('fetch_candidates_with_limit') do
          response = subject
          expect(response.body.length).to eq(1)
          candidate = response.body.first
          expect(candidate.dig('id')).to eq(15_675_032_003)
          expect(candidate.dig('first_name')).to eq('Adam')
          expect(candidate.dig('last_name')).to eq('Levin')
          expect(candidate.dig('applications').first.dig('status')).to eq('active')
        end
      end
    end

    context 'when there is no limit' do
      let(:params) { {} }

      it 'fetchs all candidates data' do
        VCR.use_cassette('fetch_all_candidates') do
          response = subject
          expect(response.status).to eq(200)
          expect(response.body.length).to eq(2)
          candidate_1 = response.body[0]
          expect(candidate_1.dig('id')).to eq(15_675_032_003)
          expect(candidate_1.dig('first_name')).to eq('Adam')
          expect(candidate_1.dig('last_name')).to eq('Levin')
          expect(candidate_1.dig('applications').first.dig('status')).to eq('active')

          candidate_2 = response.body[1]
          expect(candidate_2.dig('id')).to eq(16_084_487_003)
          expect(candidate_2.dig('first_name')).to eq('Claude')
          expect(candidate_2.dig('last_name')).to eq('Shannon')
          expect(candidate_2.dig('applications').first.dig('status')).to eq('active')

          expect(subject.status).to eq(200)
          expect(response.headers['link'].to_s).not_to include('rel="next"')
        end
      end
    end

    context 'when there is an error' do
      let(:params) { {} }

      it 'returns the error' do
        VCR.use_cassette('fetch_candidates_with_invalid_api_key') do
          response = subject
          expect(response.status).to eq(401)
          expect(response.body).to eq({ 'message' => 'Invalid Basic Auth credentials' })
        end
      end
    end
  end

  describe '#list_candidates' do
    subject(:list_candidates) { client.list_candidates(params) }
    let(:params) { {} }

    it 'calls list_many with candidates endpoint' do
      expect(client).to receive(:list_many).with('candidates', params)
      subject
    end
  end
end
