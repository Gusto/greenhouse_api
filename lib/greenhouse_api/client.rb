# frozen_string_literal: true

require 'faraday'
require 'base64'
require 'json'

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
    MAX_PER_PAGE = 500
    API_URL = 'https://harvest.greenhouse.io/v1'

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
        params: {}
      )

      if response.status == 200
        Response.new(
          body: response.body,
          headers: response.headers,
          status: response.status
        )
      else
        response
      end
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

    def request(http_method:, headers:, endpoint:, params:, body: {})
      response = Faraday.public_send(http_method) do |request|
        request.headers = headers
        request.path = "#{API_URL}/#{endpoint}"
        request.params = params
        request.body = body
      end

      Response.new(
        body: response.body && !response.body.empty? ? JSON.parse(response.body) : '',
        headers: response.headers,
        status: response.status
      )
    end
  end
end

