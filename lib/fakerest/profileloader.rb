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
    @@options = {}

    def load(profile_file, options)
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


    def configure_requests(request_mappings)
      request_mappings.each do |request_mapping|
        block = Proc.new {
          request_file_path, request_file_type = ProfileLoader.upload_file(params['file']) if(params[:file] != nil)

          content_type request_mapping.content_type
          status request_mapping.status_code
          request_body = UserRequests.generate_request_body(params, request)

          UserRequests.add  UserRequest.new(request.request_method, request.url, request_body, request_mapping.status_code, request_file_path, request_file_type)
          erb request_mapping.response_file.to_sym, params
        }

        send request_mapping.method, request_mapping.path, &block
      end
    end

    def self.upload_file(file_params)
      file_name =Time.now.strftime("%Y%m%d%H%M%S") + "_" +  file_params[:filename]
      File.open("#{@@options[:uploads]}/" + file_name, "w") do |f|
        f.write(file_params[:tempfile].read)
      end
      [file_name, file_params[:type]]
    end
  end
end
