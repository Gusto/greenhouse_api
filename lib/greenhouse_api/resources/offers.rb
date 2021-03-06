# typed: true
# frozen_string_literal: true

require 'sorbet-runtime'

module GreenhouseApi
  module Resources
    class Offers < BaseClient
      extend T::Sig

      sig { params(application_id: String).returns(Response) }
      def get_current_offer_for_application(application_id)
        response = request(
          http_method: :get,
          headers: headers,
          endpoint: "applications/#{application_id}/offers/current_offer",
        )
        compose_response(response)
      end
    end
  end
end
