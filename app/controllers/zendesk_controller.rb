require 'net/https'
require 'uri'

class ZendeskController < ApplicationController

  GS_COMPANY = "boxnet"
  ZD_COMPANY = "box"
  
  SATISFACTION_API_URL = 'https://api.getsatisfaction.com'
  ZENDESK_API_URL = "https://" + ZD_COMPANY + ".zendesk.com/api/v2"

  def index
    
  end

  def search
    @zendesk_entries = api_call(ZENDESK_API_URL + "/portal/search?query=#{params['query']}")["results"]
    @sfn_topics = api_call(SATISFACTION_API_URL + "/companies/#{GS_COMPANY}/topics.json?query=#{params['query']}")["data"]
  end

  private

  def api_call(endpoint)
    uri = URI.parse(URI.encode(endpoint))
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(uri.request_uri, {'Content-Type' => 'application/json', 'Accept'=> 'application/json'})
    response = http.request(request)
    JSON.parse(response.body)
  end

end
