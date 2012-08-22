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
end
