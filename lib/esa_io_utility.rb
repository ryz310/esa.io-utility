# frozen_string_literal: true

require 'my_api_client'
require_relative 'api_clients/esa_api_client'

queries = ['user:ryosuke_sato', 'category:unsorted']
api_client = EsaApiClient.new(access_token: ENV['ESA_IO_ACCESS_TOKEN'])
result = api_client.get_posts(*queries)

titles = []
while result.next_page do
  titles.concat(result.posts.map(&:name))
  result = api_client.get_posts(*queries, page: result.next_page)
end

puts titles
