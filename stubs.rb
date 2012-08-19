require 'rubygems'
require 'sinatra'

set :port, 1111
set :public_folder, File.dirname(__FILE__) + '/uploads'

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

  def self.load(profile_file, user_requests = [])
    @@user_requests = user_requests
    request_mappings = []
    profile_file_path = profile_file

    content = File.readlines(profile_file_path).find_all{|line| !line.strip.empty? && !line.start_with?("#")}
    content.each do |line|
      request_path, response_values = line.split("=>").collect(&:strip)
      method, path = request_path.split("|").collect(&:strip)
      response_file, content_type, status_code = response_values.split("|").collect(&:strip)
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
    File.open("uploads/" + file_name, "w") do |f|
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

if(ARGV[0] == nil || ARGV[0].empty?)
  puts "Profile File Path not provided.\n Usage: ruby stubs.rb kilkari.profile"
  exit
end
profile_file_path = ARGV[0]
ProfileLoader.load(profile_file_path)

get "/requests/:count" do
  user_requests = ProfileLoader.user_requests
  requests_count = params[:count].to_i

  start_index =  requests_count > user_requests.count ? 0 : ((user_requests.count - requests_count))
  end_index = user_requests.count
  range = start_index..end_index

  erb :requests, :locals => {:user_requests => user_requests[range].reverse}
end

get "/" do
  erb :home, :locals => {:current_profile => profile_file_path}
end


