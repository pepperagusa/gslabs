require 'net/https'
require 'uri'

class TopicfeedController < ApplicationController

  SATISFACTION_API_URL = 'https://api.getsatisfaction.com'

  def index
  end

  def topics
    result = api_call("/topics.json")

    @topics = result["data"]

    @companies = Hash.new #mapping ID <-> logo
    @topics.each { |topic|
      topic_id = topic["company_id"]
      puts topic_id
      @companies[topic_id] = api_call("/companies/#{topic_id}.json")['logo']
    }

    render :layout => false
  end

  private

  def api_call(endpoint)
    uri = URI.parse(URI.encode(SATISFACTION_API_URL + endpoint))
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(uri.request_uri, {'Content-Type' => 'application/json', 'Accept'=> 'application/json'})
    response = http.request(request)
    JSON.parse(response.body)
  end

end
