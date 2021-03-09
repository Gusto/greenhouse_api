# typed: true
# frozen_string_literal: true

require 'sorbet-runtime'

module GreenhouseApi
  module Resources
    class Candidates < Client
      extend T::Sig

      sig { params(params: T.nilable(T::Hash[String, T.any(Integer, String)])).returns(Response) }
      def self.list_candidates(params = {})
        list_many('candidates', params)
      end
    end
  end
end
