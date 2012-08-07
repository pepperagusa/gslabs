require 'net/https'
require 'uri'

class UsersearchController < ApplicationController

  SATISFACTION_API_URL = 'https://api.getsatisfaction.com'

  def index
  end

  def login
    result = api_call("/me.json", params['username'], params['password'])
    puts "--------------------My User ID: #{result['id']}----------------------"
    if result['id'] == nil then
      session[:is_valid] = false
    else
      session[:is_valid] = true

      session[:username] = params['username']
      session[:password] = params['password']
    end
    respond_to do
      |format| format.html { render :nothing => true }
    end
  end
  
  def logout
    session[:is_valid] = false
    respond_to do
      |format| format.html { render :nothing => true }
    end
  end

  def topics
    session[:company_id] = api_call("/companies/#{params['company_slug']}.json", session[:username], session[:password])['id']
    session[:member_email] = params['member_email']

    @this_member = api_call("/people.json?email=#{session[:member_email]}", session[:username], session[:password])

    all_topics = api_call("/people/#{@this_member['id']}/topics.json?sort=recently_active", session[:username], session[:password])["data"]
    puts "-------username: #{session[:username]} ------------"

    @topics = Array.new

    all_topics.each { |t|
      if (t['company_id'].to_s == session[:company_id].to_s) then
        @topics.push(t)
      end
    }
    render :layout => false
  end

  private

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

end
