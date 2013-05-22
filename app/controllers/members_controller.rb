require 'rubygems'
require 'net/https'
require 'uri'
require 'oauth'

class MembersController < ApplicationController

  SATISFACTION_API_URL = 'https://api.getsatisfaction.com'

  def index
    if !session[:is_valid] then
      redirect_to "/other/login?return_url=/members"
    end
  end

  def people
    @current_page = 1

    if params['fastpasskey'] then session[:fastpasskey] = params['fastpasskey'] end
    if params['fastpasssecret'] then session[:fastpasssecret] = params['fastpasssecret'] end
    if params['page'] then @current_page = params['page'].to_i end
    
    @something_wrong = false

    if session[:companyId] then
      @filter = params['filter']
      puts "------------------- #{session[:fastpasskey]} --------------"
      case @filter
        when 'visited' then @filter_label = "Everyone"
        when 'employees' then @filter_label = "Employees"
      else
        @filter_label = "Contributors"
      end
      
      result = api_call("/companies/#{session[:companyId]}/people.json?page=#{@current_page}&filter=#{@filter}")
  
      @people = result["data"]
      @total_people = result["total"].to_i
      @pages = (@total_people / 30.0).ceil
    else
      @something_wrong = true
    end
    render :layout => false
  end

  def topics
    if params['userId']
      
      flash[:info] = nil
      
      if params['deleteidentity'] == '1'
        consumer = OAuth::Consumer.new(session[:fastpasskey], session[:fastpasssecret], :site => SATISFACTION_API_URL, :http_method => :delete)
        access_token = OAuth::AccessToken.new(consumer)
        request_headers = {'Content-Type' => 'application/json'}
        response = access_token.delete("/people/#{params['userId']}/identity.json", request_headers)
        (response.code == "200") ? flash[:info] = "Identity deleted successfully" : flash[:info] = "Could not delete the Fastpass identity!"
      end
      
      result = api_call_2_legged("/people/#{params['userId']}/identity.json", session[:fastpasskey], session[:fastpasssecret])
      if result.has_key?("nodata") then
        @identity = { }
      else
        @identity = result["custom_attributes"]
      end
      
      result = api_call("/people/#{params['userId']}/followed/topics.json?limit=30")
      all_topics = result["data"]
      @topics = Array.new
  
      all_topics.each { |t|
        if (t['company_id'].to_s == session[:companyId].to_s) then
          @topics.push(t)
        end
      }
  
      @this_user = api_call("/people/#{params['userId']}.json")
        
    end

    render :layout => false

  end

end