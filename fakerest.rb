require 'rubygems'
require 'yaml'
require 'optparse'


module FakeRest

  class ArgumentsParser

    def parse(args)
      options = {}

      optparse = OptionParser.new do |opts|
        opts.banner = "Usage: fakerest.rb [options]"

        options[:port] = 1111
        options[:config] = nil
        options[:views] = 'views/'
        options[:uploads] = 'uploads/'

        opts.on("-c","--config CONFIG_FILE","Confilg file to load request mappings (required)") do |cfg|
          options[:config] = cfg
        end

        opts.on("-p","--port PORT","Port on which the fakerest to be run. Default = 1111") do |prt|
          options[:port] = prt
        end

        opts.on("-w","--views VIEWS_FOLDER","Folder path that contains the views (required)") do |views|
          options[:views] = views
        end

        opts.on("-u","--uploads UPLOADS_FOLDER","Folder to which any file uploads to be stored (required)") do |uploads|
          options[:uploads] = uploads
        end

        opts.on( "-h", "--help", "Displays help message" ) do
          puts opts
          exit
        end
      end
      optparse.parse!(args)


      if(options[:config] == nil)
        puts optparse
        exit(-1)
      end

      options
    end
  end



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

  class UserRequest
    attr_reader :response_status_code, :url, :body, :method, :request_file_path, :request_file_type
    def initialize(method, url, body, response_status_code, request_file_path = "", request_file_type = "")
      @method = method
      @url = url
      @body = body
      @response_status_code = response_status_code
      @request_file_path = request_file_path
      @request_file_type = request_file_type
    end

    def to_s
      "#{method} #{url} #{response_status_code}\n#{body}\n\n"
    end
  end

  class ProfileLoader
    @@user_requests = []
    @@options = {}

    def self.load(profile_file, options)
      @@options = options
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

    def self.configure_requests(request_mappings)
      request_mappings.each do |request_mapping|
        block = Proc.new {
          request_file_path, request_file_type = ProfileLoader.upload_file(params['file']) if(params[:file] != nil)

          content_type request_mapping.content_type
          status request_mapping.status_code
          request_body = ProfileLoader.generate_request_body(params, request)

          @@user_requests << UserRequest.new(request.request_method, request.url, request_body, request_mapping.status_code, request_file_path, request_file_type)
          erb request_mapping.response_file.to_sym, params
        }

        send request_mapping.method, request_mapping.path, &block
      end
    end

    def self.upload_file(file_params)
      file_name = file_params[:filename] + Time.now.strftime("%Y%m%d%H%M%S")
      File.open("#{@@options[:uploads]}" + file_name, "w") do |f|
        f.write(file_params[:tempfile].read)
      end
      [file_name, file_params[:type]]
    end

    def self.generate_request_body(params, request)
      request_body = "Params are: "
      params.each do |key, value|
        next if key == 'file' or key == 'splat' or key == 'captures'
        request_body += value != nil ? (key + "=" + value + ",") : (key + ",")
      end
      request_body += "\nBody is: " + request.body.read
      request_body
    end

    def self.user_requests
      @@user_requests
    end
  end
end

options = FakeRest::ArgumentsParser.new.parse(ARGV)

require 'sinatra'

set :port, options[:port]
set :views, options[:views]

profile_file_path = options[:config]

FakeRest::ProfileLoader.load(profile_file_path, options)

get "/requests/:count" do
  user_requests = FakeRest::ProfileLoader.user_requests
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

