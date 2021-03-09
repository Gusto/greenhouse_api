# typed: true
# frozen_string_literal: true

require 'sorbet-runtime'

module GreenhouseApi
  module Resources
    class Users < Client
      extend T::Sig

      sig { params(first_name: String, last_name: String, email: String, on_behalf_of_id: String, additional_args: T.any(T::Boolean, String)).returns(Response) }
      def self.create_user(first_name:, last_name:, email:, on_behalf_of_id:, **additional_args)
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
      def self.disable_user(user, on_behalf_of_id)
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
      def self.enable_user(user, on_behalf_of_id)
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
    end
  end
end
