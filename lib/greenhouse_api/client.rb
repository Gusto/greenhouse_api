# typed: true
# frozen_string_literal: true

require 'faraday'
require 'base64'
require 'json'
require 'sorbet-runtime'

module GreenhouseApi
  class Response
    attr_reader :headers, :body, :status

    def initialize(headers:, body:, status:)
      @headers = headers
      @body = body
      @status = status
    end
  end

  class Client
    extend T::Sig

    MAX_PER_PAGE = 500
    ON_BEHALF_OF = 'On-Behalf-Of'
    API_URL = 'https://harvest.greenhouse.io'

    def initialize(api_key)
      @api_key = api_key
    end

    def list_candidates(params = {})
      list_many('candidates', params)
    end

    def get_current_offer_for_application(application_id)
      response = request(
        http_method: :get,
        headers: headers,
        endpoint: "applications/#{application_id}/offers/current_offer",
      )
      compose_response(response)
    end

    sig { params(first_name: String, last_name: String, email: String, on_behalf_of_id: String, additional_args: T.any(T::Boolean, String)).returns(Response) }
    def create_user(first_name:, last_name:, email:, on_behalf_of_id:, **additional_args)
      body = { first_name: first_name, last_name: last_name, email: email }.merge(additional_args).to_json
      response = request(
        http_method: :post,
        headers: headers.merge(ON_BEHALF_OF => on_behalf_of_id),
        endpoint: "users",
        body: body
      )
      compose_response(response)
    end

    sig { params(user: T::Hash[String, T.any(Integer, String)], on_behalf_of_id: String).returns(Response) }
    def disable_user(user, on_behalf_of_id)
      body = { user: user }.to_json
      response = request(
        http_method: :patch,
        headers: headers.merge(ON_BEHALF_OF => on_behalf_of_id),
        endpoint: "users/disable",
        body: body,
        api_version: 'v2'
      )
      compose_response(response)
    end

    sig { params(user: T::Hash[String, T.any(Integer, String)], on_behalf_of_id: String).returns(Response) }
    def enable_user(user, on_behalf_of_id)
      body = { user: user }.to_json
      response = request(
        http_method: :patch,
        headers: headers.merge(ON_BEHALF_OF => on_behalf_of_id),
        endpoint: "users/enable",
        body: body,
        api_version: 'v2'
      )
      compose_response(response)
    end

    def list_many(resource, params = {})
      limit = params.delete(:limit)
      page = params[:page] || 1
      data = []
      response = nil

      loop do
        per_page = if params[:per_page]
          params[:per_page]
        else
          limit ? [limit - data.length, MAX_PER_PAGE].min : MAX_PER_PAGE
        end

        response = request(
          http_method: :get,
          headers: headers,
          endpoint: resource,
          params: params.merge(page: page, per_page: per_page)
        )
        break if response.status != 200

        data.concat(response.body)

        if last_page?(response) || data_limit_reached?(data, limit) || params[:page]
          break
        else
          page += 1
        end
      end

      if response.status == 200
        Response.new(
          body: data,
          headers: response.headers,
          status: response.status
        )
      else
        response
      end
    end

    private

    def last_page?(response)
      !response.headers['link'].to_s.include?('rel="next"')
    end

    def data_limit_reached?(data, limit)
      limit && data.length >= limit
    end

    def headers
      credential = Base64.strict_encode64(@api_key + ':')

      {
        'Authorization' => 'Basic ' + credential,
      }
    end

    def request(http_method:, headers:, endpoint:, params: {}, body: {}, api_version: 'v1')
      response = Faraday.public_send(http_method) do |request|
        request.headers = headers
        request.path = "#{API_URL}/#{api_version}/#{endpoint}"
        request.params = params
        request.body = body
      end

      Response.new(
        body: response.body && !response.body.empty? ? JSON.parse(response.body) : '',
        headers: response.headers,
        status: response.status
      )
    end

    def compose_response(response)
      if [200, 201].include?(response&.status)
        Response.new(
          body: response.body,
          headers: response.headers,
          status: response.status
        )
      else
        response
      end
    end
  end
end

