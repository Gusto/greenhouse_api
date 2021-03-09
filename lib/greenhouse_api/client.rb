# typed: false
# frozen_string_literal: true

module GreenhouseApi
  class Client
    def initialize(api_key)
      @api_key = api_key
    end

    def list_many(resource, params = {})
      base_client.list_many(resource, params)
    end
    
    def list_candidates(params = {})
      candidates_client.list_all(params)
    end

    def get_current_offer_for_application(application_id)
      offers_client.get_current_offer_for_application(application_id)
    end

    def create_user(first_name:, last_name:, email:, on_behalf_of_id:, **additional_args)
      users_client.create_user(first_name: first_name, last_name: last_name, email: email, on_behalf_of_id: on_behalf_of_id, **additional_args)
    end

    def disable_user(user, on_behalf_of_id)
      users_client.disable_user(user, on_behalf_of_id)
    end

    def enable_user(user, on_behalf_of_id)
      users_client.enable_user(user, on_behalf_of_id)
    end

    private

    def candidates_client
      @candidates_client ||= ::Resources::Candidates.new(api_key)
    end

    def offers_client
      @offers_client ||= ::Resources::Offers.new(api_key)
    end

    def users_client
      @users_client ||= ::Resources::Users.new(api_key)
    end

    def base_client
      @base_client ||= ::BaseClient.new(api_key)
    end
  end
end
