# typed: false
# frozen_string_literal: true

require 'greenhouse_api/resources/candidates'

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

    context 'when there is page param' do
      let(:params) { { page: 3, per_page: 5 } }

      it 'returns just one page' do
        VCR.use_cassette('fetch_a_specific_candidate_page') do
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
    subject(:list_candidates) { client.candidates.list_candidates(params) }
    let(:params) { {} }

    it 'calls list_many with candidates endpoint' do
      expect(client).to receive(:list_many).with('candidates', params)
      subject
    end
  end

  describe '#get_current_offer_for_application' do
    subject(:get_current_offer_for_application) { client.offers.get_current_offer_for_application(application_id) }
    let(:application_id) { 123_456 }

    context 'when there is a current offer for the application' do
      it 'fetches the offer data' do
        VCR.use_cassette('get_current_offer_for_application') do
          response = subject
          expect(response.status).to eq(200)
          expect(response.body.dig('id')).to eq(4_181_733_003)
          expect(response.body.dig('application_id')).to eq(123_456)
          expect(response.body.dig('sent_at')).to eq(nil)
          expect(response.body.dig('starts_at')).to eq('2020-12-04')
          expect(response.body.dig('candidate_id')).to eq(19_301_049_003)
          expect(response.body.dig('job_id')).to eq(4_159_343_003)
        end
      end
    end

    context 'when there is not a current offer' do
      let(:application_id) { 789_123 }

      it 'returns not found' do
        VCR.use_cassette('get_unfound_current_offer_for_application') do
          response = subject
          expect(response.status).to eq(404)
          expect(response.body).to eq({ 'message' => 'Resource not found' })
        end
      end
    end
  end

  describe 'users' do
    let(:on_behalf_of_id) { '4198051003' }
    let(:employee_id) { '30928902' }
    let(:user_id) { '4315648003' }
    let(:email) { 'pikachu@testing.com' }

    describe '#create_user' do
      subject(:create_user) do
        client.users.create_user(
          first_name: first_name,
          last_name: last_name,
          email: email,
          on_behalf_of_id: on_behalf_of_id,
          employee_id: employee_id
        )
      end
      let(:first_name) { 'Pika' }
      let(:last_name) { 'Pikachu' }

      context 'when successful' do
        it 'creates user' do
          VCR.use_cassette('create_user') do
            response = subject
            expect(response.status).to eq(201)
            expect(response.body.dig('id')).to eq(user_id.to_i)
            expect(response.body.dig('name')).to eq('Pika Pikachu')
            expect(response.body.dig('primary_email_address')).to eq(email)
            expect(response.body.dig('disabled')).to eq(false)
            expect(response.body.dig('site_admin')).to eq(false)
          end
        end
      end

      context 'when there is an error' do
        let(:email) { '' }

        it 'returns the error' do
          VCR.use_cassette('create_user_with_missing_field') do
            response = subject
            expect(response.status).to eq(422)
            expect(response.body).to eq(
              {
                "errors" => [
                  { "field" => "email", "message" => "Missing required field: email" },
                  { "field" => "email", "message" => "Invalid email address." }
                ]
              }
            )
          end
        end
      end
    end

    describe '#disable_user' do
      subject(:disable_user) { client.users.disable_user(user, on_behalf_of_id) }

      context 'with email' do
        let(:user) { { email: email } }

        it 'disables user' do
          VCR.use_cassette('disable_user_with_email') do
            response = subject
            expect(response.status).to eq(200)
            expect(response.body.dig('id')).to eq(user_id.to_i)
            expect(response.body.dig('name')).to eq('Pika Pikachu')
            expect(response.body.dig('disabled')).to eq(true)
          end
        end
      end

      context 'with user_id' do
        let(:user) { { user_id: user_id } }

        it 'disables user' do
          VCR.use_cassette('disable_user_with_user_id') do
            response = subject
            expect(response.status).to eq(200)
            expect(response.body.dig('id')).to eq(user_id.to_i)
            expect(response.body.dig('name')).to eq('Pika Pikachu')
            expect(response.body.dig('disabled')).to eq(true)
          end
        end
      end

      context 'with employee_id' do
        let(:user) { { employee_id: employee_id } }

        it 'disables user' do
          VCR.use_cassette('disable_user_with_employee_id') do
            response = subject
            expect(response.status).to eq(200)
            expect(response.body.dig('id')).to eq(user_id.to_i)
            expect(response.body.dig('name')).to eq('Pika Pikachu')
            expect(response.body.dig('disabled')).to eq(true)
          end
        end
      end

      context 'when there is an error' do
        let(:user) { {} }

        it 'returns the error' do
          VCR.use_cassette('disable_user_with_missing_field') do
            response = subject
            expect(response.status).to eq(400)
            expect(response.body).to eq({ 'message' => 'Invalid JSON Payload' })
          end
        end
      end
    end

    describe '#enable_user' do
      subject(:enable_user) { client.users.enable_user(user, on_behalf_of_id) }

      context 'with email' do
        let(:user) { { email: email } }

        it 'enables user' do
          VCR.use_cassette('enable_user_with_email') do
            response = subject
            expect(response.status).to eq(200)
            expect(response.body.dig('id')).to eq(user_id.to_i)
            expect(response.body.dig('name')).to eq('Pika Pikachu')
            expect(response.body.dig('disabled')).to eq(false)
          end
        end
      end

      context 'with user_id' do
        let(:user) { { user_id: user_id} }

        it 'enables user' do
          VCR.use_cassette('enable_user_with_user_id') do
            response = subject
            expect(response.status).to eq(200)
            expect(response.body.dig('id')).to eq(user_id.to_i)
            expect(response.body.dig('name')).to eq('Pika Pikachu')
            expect(response.body.dig('disabled')).to eq(false)
          end
        end
      end

      context 'with employee_id' do
        let(:user) { { employee_id: employee_id } }

        it 'enables user' do
          VCR.use_cassette('enable_user_with_employee_id') do
            response = subject
            expect(response.status).to eq(200)
            expect(response.body.dig('id')).to eq(user_id.to_i)
            expect(response.body.dig('name')).to eq('Pika Pikachu')
            expect(response.body.dig('disabled')).to eq(false)
          end
        end
      end

      context 'when there is an error' do
        let(:user) { {} }

        it 'returns the error' do
          VCR.use_cassette('enable_user_with_missing_field') do
            response = subject
            expect(response.status).to eq(400)
            expect(response.body).to eq({ 'message' => 'Invalid JSON Payload' })
          end
        end
      end
    end

    context 'when on_behalf_of user is invalid' do
      subject(:enable_user) { client.users.enable_user(user, on_behalf_of_id) }
      let(:user) { { email: email } }
      let(:on_behalf_of_id) { '3895753' }

      it 'returns the error' do
        VCR.use_cassette('enable_user_on_behalf_of_invalid_user') do
          response = subject
          expect(response.status).to eq(404)
          expect(response.body).to eq({ 'message' => 'Resource not found' })
        end
      end
    end

    context 'when on_behalf_of user is invalid' do
      subject(:enable_user) { client.users.enable_user(user, on_behalf_of_id) }
      let(:user) { { email: email } }
      let(:on_behalf_of_id) { '4198040003' }

      it 'returns the error' do
        VCR.use_cassette('enable_user_on_behalf_of_bad_permissions') do
          response = subject
          expect(response.status).to eq(403)
          expect(response.body).to eq({ "errors" => [{ 'message' => 'Access denied' }] })
        end
      end
    end
  end
end
