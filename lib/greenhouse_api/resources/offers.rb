# typed: true
# frozen_string_literal: true

require 'sorbet-runtime'

module GreenhouseApi
  module Resources
    class Offers < Client
      extend T::Sig

      sig { params(application_id: String).returns(Response) }
      def self.get_current_offer_for_application(application_id)
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
