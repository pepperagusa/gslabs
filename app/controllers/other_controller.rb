require 'net/https'
require 'uri'

class OtherController < ApplicationController

  SATISFACTION_API_URL =  "https://api.getsatisfaction.com"

  # Fastpass pair for pepperagusa
  FASTPASS_KEY    = "62628zw63njo"
  FASTPASS_SECRET = "m6zc7qfx2s749zy57pre6w23589b1ke4"

  def get_fastpass_uid
    canonicalName = params['canonical']
    respond_to do |format|
      if canonicalName then
        identity = api_call_2_legged("/people/#{canonicalName}/identity")
        if !identity["nodata"] and identity["custom_attributes"] then
          @fastpassUid = identity["custom_attributes"]["uid"]
        end
        format.json { render :layout => false, :text => "{ \"fastpass_uid\" : \"#{@fastpassUid}\" }" }
      end
    end
  end
  
  def api_call(endpoint)
    uri = URI.parse(URI.encode(SATISFACTION_API_URL + endpoint))
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri, {'Content-Type' => 'application/json', 'Accept'=> 'application/json'})
    response = http.request(request)
    JSON.parse(response.body)
  end
  
  def api_call_2_legged(endpoint)
    consumer = OAuth::Consumer.new(FASTPASS_KEY, FASTPASS_SECRET, :site => SATISFACTION_API_URL, :http_method => :get)
    access_token = OAuth::AccessToken.new(consumer)
    request_headers = {'Content-Type' => 'application/json'}
    response = access_token.get(endpoint, request_headers)
    (response.code == "200") ? JSON.parse(response.body) : { "nodata" => "true"}
  end
  
end