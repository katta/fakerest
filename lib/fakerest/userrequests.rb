module FakeRest  
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

  class UserRequests
    @@user_requests = []

    def self.generate_request_body(params, request)
      request_body = "Params are: "
      params.each do |key, value|
        next if key == 'file' or key == 'splat' or key == 'captures'
        request_body += value != nil ? (key + "=" + value + ",") : (key + ",")
      end
     
      request_body += "\nBody is: " + request.body.read
      request_body
    end

    def self.add(user_request)
      @@user_requests << user_request
    end

    def self.user_requests
      @@user_requests
    end
  end
end
