require 'test/unit'
require 'fakerest/userrequests'
require 'mocha'

include FakeRest

class UserRequestsTest < Test::Unit::TestCase
  def test_add_new_user_request
    user_request = UserRequest.new("post", "/customer/1", "body", 200)

    UserRequests.add user_request

    user_requests = UserRequests.user_requests
    
    assert_equal(1, user_requests.size)
    req = user_requests[0]

    assert_equal("post", req.method)
    assert_equal("/customer/1", req.url)
    assert_equal("body", req.body)
    assert_equal(200, req.response_status_code)
  end

  def test_request_body_should_have_params_and_body
    params = {"id" => "10"}
    body = mock("body")
    request = mock("request")
    request.expects(:body).returns(body)
    body.expects(:read).returns("this is body")

    body = UserRequests.generate_request_body(params, request)
  
    assert(body.include? "id=10")
    assert(body.include? "this is body")
  end


  def test_request_body_should_not_contain_file_spat_and_captures_params
    params = {"file" => "some file", "spat" => "spat value", "id" => "10"}
    body = mock("body")
    request = mock("request")
    request.expects(:body).returns(body)
    body.expects(:read).returns("this is body")
    
    body = UserRequests.generate_request_body(params, request)
  
    puts body
    assert_equal(true, (body.include? "id=10"), "expected param id")
    assert_equal(false, (body.include? "splat"), "unexpected param splat")
    assert_equal(false, (body.include? "captures"), "unexpected param captures")
    assert_equal(false, (body.include? "file"), "unexpected param file")
  end

end
