require 'rubygems'
require 'yaml'
require 'fakerest/argumentsparser'
require 'fakerest/userrequests'
require 'fakerest/profileloader'

options = FakeRest::ArgumentsParser.new.parse(ARGV)

require 'sinatra'

set :port, options[:port]
set :views, options[:views]
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

  requests_template = '<%= "No requests found" if user_requests.empty? %>
 <% user_requests.each do |request| %>
   <%= "<b>Method:</b> #{request.method} <b>Status:</b> #{request.response_status_code} <b>URL:</b> #{request.url}" %></br>
   <pre><%= request.body %></pre>
   <% if request.request_file_path != nil %>
     <a href="/<%= request.request_file_path%>"><%= request.request_file_path%></a><br/>
     Type: <%= request.request_file_type%>
   <% end %>
   <hr/>
 <% end %>'

 erb requests_template, :locals => {:user_requests => user_requests[range].reverse}
end

get "/" do

  template = '<div>
  Current Profile : <%= current_profile%> 
</div>
<br/>'

erb template, :locals => {:current_profile => profile_file_path}
end

