# frozen_string_literal: true

class EsaApiClient < MyApiClient::Base
  endpoint 'https://api.esa.io/v1/teams/feedforce'

  error_handling status_code: 500..599, raise: MyApiClient::ServerError
  error_handling status_code: 400..499, raise: MyApiClient::ClientError
  error_handling status_code: 423, with: :too_many_requests
  retry_on Errors::TooManyRequests, wait: 0.seconds

  attr_reader :access_token

  def initialize(access_token:)
    @access_token = access_token
  end

  def get_posts(*search, page: nil, per_page: 20)
    query = { q: search.join(' '), per_page: per_page }
    query.merge!(page: page) if page.present?
    get 'posts', headers: headers, query: query
  end

  def update_post(number:, name:, category:, message: 'Update post.', skip_notice: true)
    message = "[skip notice] #{message}" if skip_notice
    body = {
      post: {
        name: name,
        category: category,
        message: message,
      }
    }

    patch "posts/#{number}", headers: headers, body: body
  end

  private

  def headers
    {
      'Authorization': "Bearer #{access_token}",
      'Content-Type': 'application/json',
    }
  end

  def too_many_requests(params, logger)
    logger.warn('The API limit exceeded.')
    waiting_seconds = params.response.headers['retry-after'].to_i + 3
    logger.warn("To be wait #{waiting_seconds} sec.")
    sleep(waiting_seconds)
    raise Errors::TooManyRequests
  end
end
