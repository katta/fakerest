require 'rubygems'
require 'yaml'
require 'fakerest/argumentsparser'
require 'fakerest/userrequests'
require 'fakerest/profileloader'

options = FakeRest::ArgumentsParser.new.parse(ARGV)

require 'sinatra'

set :port, options[:port]
set :bind, options[:bind]
set :views, options[:views]
set :public_folder, options[:uploads]
set :static, true
set :run, true

profile_file_path = options[:config]

profile_loader = FakeRest::ProfileLoader.new
profile_loader.load(profile_file_path, options)

get "/requests/:count" do
  user_requests = FakeRest::UserRequests.user_requests
  requests_count = params[:count].to_i

  start_index =  requests_count > user_requests.count ? 0 : ((user_requests.count - requests_count))
  end_index = user_requests.count
  range = start_index..end_index

  content_type :json
  user_requests[range].reverse.to_json
end

get "/" do

  template = '<div>
  Current Profile : <%= current_profile%>
  </div>
  <br/>'

  erb template, :locals => {:current_profile => profile_file_path}
end

