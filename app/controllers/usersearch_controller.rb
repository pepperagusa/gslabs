require 'net/https'
require 'uri'

class UsersearchController < ApplicationController

  SATISFACTION_API_URL = 'https://api.getsatisfaction.com'

  def index
    if !session[:is_valid] then
      redirect_to "/other/login?return_url=/usersearch"
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

end
