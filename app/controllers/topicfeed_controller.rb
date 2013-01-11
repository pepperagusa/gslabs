require 'net/https'
require 'uri'

class TopicfeedController < ApplicationController

  SATISFACTION_API_URL = 'https://api.getsatisfaction.com'

  def index
    session[:last_topic_id] = 1
  end

  def topics
    result = api_call("/topics.json?limit=8")

    @topics = result["data"]

    @companies = Hash.new #mapping ID <-> logo
    @topics.each { |topic|
      company_id = topic["company_id"]
      puts "[T-#{topic['id']}] [C-#{company_id}]"
      @companies[company_id] = api_call("/companies/#{company_id}.json")['logo']
    }

    render :layout => false
  end

  def last_topic
    result = api_call("/topics.json?limit=1")

    @new_topic = false
    @topic = result["data"][0]

    if session[:last_topic_id] != @topic['id']
      @new_topic = true
      session[:last_topic_id] = @topic['id']
      company_id = @topic["company_id"]
      puts "[T-#{@topic['id']}] [C-#{company_id}]"
      @company_logo = api_call("/companies/#{company_id}.json")['logo']
    else
      random_topic_id = session[:last_topic_id].to_i - rand(10000)
      puts "Random ID: #{random_topic_id} --> call /topics/#{random_topic_id}.json"
      @topic = api_call("/topics/#{random_topic_id}.json")
      @new_topic = true
#      session[:last_topic_id] = @topic['id']
      company_id = @topic["company_id"]
      puts "[T-#{@topic['id']}] [C-#{company_id}]"
      @company_logo = api_call("/companies/#{company_id}.json")['logo']
    end
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
