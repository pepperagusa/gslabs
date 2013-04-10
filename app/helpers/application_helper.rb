module ApplicationHelper

  def api_call(endpoint, username = "", password = "")
    uri = URI.parse(URI.encode(SATISFACTION_API_URL + endpoint))
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(uri.request_uri, {'Content-Type' => 'application/json', 'Accept'=> 'application/json'})
    if (username != "" and password != "")
      request.basic_auth(username, password)
    end
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
