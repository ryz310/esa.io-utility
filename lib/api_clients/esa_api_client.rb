# frozen_string_literal: true

class EsaApiClient < MyApiClient::Base
  endpoint 'https://api.esa.io/v1/teams/feedforce'

  error_handling status_code: 423, with: :too_many_requests
  retry_on Errors::TooManyRequests, wait: 0.seconds

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

  def too_many_requests(params, logger)
    logger.warn('The API limit exceeded.')
    reset_on = params.response.headers['X-RateLimit-Reset']
    waiting_seconds = Time.at(reset_on) - Time.current
    logger.warn("To be wait #{waiting_seconds} sec.")
    sleep(waiting_seconds) if waiting_seconds.positive?
    raise Errors::TooManyRequests
  end
end
