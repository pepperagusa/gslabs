require 'net/https'
require 'uri'

class OtherController < ApplicationController

  def login
  end
  
  def login_action
    result = api_call("/me.json", params[:loginform][:username], params[:loginform][:password])

    puts "--------------------My User ID: #{result['id']} #{params[:loginform][:username]}, #{params[:loginform][:password]}----------------------"
    if result['id'] then
      session[:is_valid] = true
      session[:username] = params[:loginform][:username]
      session[:password] = params[:loginform][:password]
      session[:companyId] = api_call("/companies/#{params[:loginform][:company_name]}.json", session[:username], session[:password])['id']
      puts "===============#{params[:loginform][:return_url]}=============="
      redirect_to params[:loginform][:return_url]
    else
      session[:is_valid] = false
      flash[:error] = "Login failed"
      redirect_to "/other/login"
    end
  end
  
  def logout
    reset_session
    session[:is_valid] = false
    
    redirect_to "/"
  end


  # this method returns a JSON with the faspass UID of a given canonical_name
  # e.g. /other/get_fastpass_uid.json?canonical=pepperagusa
  def get_fastpass_data
    canonicalName = params['canonical']
    respond_to do |format|
      if canonicalName then
        identity = api_call_2_legged("/people/#{canonicalName}/identity")
        if !identity["nodata"] and identity["custom_attributes"] then
          identity = identity["custom_attributes"]
        end
        format.json { render :layout => false, :text => "#{identity}" }
      end
    end
  end
  
end