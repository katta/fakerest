require 'test/unit'
require 'fakerest/argumentsparser'

class ArgumentsParserTest < Test::Unit::TestCase

  def setup
    @parser = FakeRest::ArgumentsParser.new
  end

  def test_should_check_for_mandatory_config_argument
    options = @parser.parse(["-c","config"])

    assert_equal("config", options[:config], "Expected config argument but not found.")
  end

  def test_default_port_is_1111
    options = @parser.parse(["-c" , "config"])

    assert_equal(1111, options[:port], "Expected default port to be 1111")
  end

  def test_should_override_default_port
    options = @parser.parse(["-c" , "config", "-p", "2222"])

    assert_equal("2222", options[:port] )
  end

  def test_default_binding_is_localhost
    options = @parser.parse(["-c" , "config"])

    assert_equal("localhost", options[:bind], "Expected default binding to be localhost")
  end

  def test_should_override_default_binding
    options = @parser.parse(["-c" , "config", "-o", "0.0.0.0"])

    assert_equal("0.0.0.0", options[:bind] )
  end

  def test_should_override_default_views_folder
    options = @parser.parse(["-c" , "config", "-w", "v1"])

    assert_equal("v1", options[:views])
  end

  def test_default_views_folder
    options = @parser.parse(["-c" , "config"])

    assert_equal("views" , options[:views])
  end
  
  def test_should_override_default_uploads_folder
    options = @parser.parse(["-c" , "config", "-u", "v1"])

    assert_equal("v1", options[:uploads])
  end
  
  def test_default_uploads_folder
    options = @parser.parse(["-c" , "config"])

    assert_equal("uploads" , options[:uploads])
  end
end
