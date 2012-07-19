require 'net/https'
require 'uri'

class MembersController < ApplicationController

  SATISFACTION_API_URL = 'https://api.getsatisfaction.com'

  def index
  end

  def people
    @current_page = 1
    if params['page'] then
      @current_page = params['page'].to_i
    end
    @company_slug = params['companyslug']
    
    @filter = params['filter']
    case @filter
      when 'visited' then @filter_label = "Everyone"
      when 'employees' then @filter_label = "Employees"
    else
      @filter_label = "Contributors"
    end
    
    result = api_call("/companies/#{@company_slug}/people.json?page=#{@current_page}&filter=#{@filter}")

    @people = result["data"]
    @total_people = result["total"].to_i
    @pages = (@total_people / 30.0).ceil
  end

  def topics
    result = api_call("/people/#{params['userId']}/followed/topics.json")
    @topics = result["data"]
    @total_topics = result["total"]
    
    this_user = api_call("/people/#{params['userId']}.json")
    @this_user_name = this_user['name']
    @this_user_avatar = this_user['avatar_url_medium']
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
