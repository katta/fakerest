require 'rubygems'
require 'yaml'
require 'fakerest/argumentsparser'
require 'fakerest/userrequests'


module FakeRest

  class RequestMapping
    attr_reader :status_code, :response_file, :content_type, :method, :path
    def initialize(method, path, status_code, response_file, content_type)
      @method = method
      @path = path
      @status_code = status_code
      @response_file = response_file
      @content_type = content_type
    end
  end

  class ProfileLoader
    @options = {}

    def load(profile_file, options)
      @options = options
      request_mappings = []
      profile_file_path = profile_file

      defns = YAML::load_documents(File.open(profile_file_path))
      defns.each do |doc|
        method = doc['method']
        path = doc['path']

        response = doc['response']
        response_file = response['content_file']
        content_type = response['content_type']
        status_code = response['status_code']

        request_mappings << RequestMapping.new(method, path, status_code, response_file, content_type)
      end

      configure_requests(request_mappings)
    end
    

    def configure_requests(request_mappings)
      request_mappings.each do |request_mapping|
        block = Proc.new {
          request_file_path, request_file_type = upload_file(params['file']) if(params[:file] != nil)

          content_type request_mapping.content_type
          status request_mapping.status_code
          request_body = UserRequests.generate_request_body(params, request)

          UserRequests.add  UserRequest.new(request.request_method, request.url, request_body, request_mapping.status_code, request_file_path, request_file_type)
          erb request_mapping.response_file.to_sym, params
        }

        send request_mapping.method, request_mapping.path, &block
      end
    end

    def upload_file(file_params)
      file_name = file_params[:filename] + Time.now.strftime("%Y%m%d%H%M%S")
      File.open("#{@options[:uploads]}/" + file_name, "w") do |f|
        f.write(file_params[:tempfile].read)
      end
      [file_name, file_params[:type]]
    end

  end
end

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

