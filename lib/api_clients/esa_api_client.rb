# frozen_string_literal: true

class EsaApiClient < MyApiClient::Base
  endpoint 'https://api.esa.io/v1/teams/feedforce'

  attr_reader :access_token

  def initialize(access_token:)
    @access_token = access_token
  end

  def get_posts(*search, page: nil)
    query = { q: search.join(' ') }
    query.merge!(page: page) if page.present?
    get 'posts', headers: headers, query: query
  end

  private

  def headers
    { Authorization: "Bearer #{access_token}" }
  end
end
