require 'test/unit'
require 'fakerest/argumentsparser'

class ArgumentsParserTest < Test::Unit::TestCase
  def test_should_check_for_mandatory_config_argument
    parser = FakeRest::ArgumentsParser.new
    options = parser.parse(["-c","config"])

    assert_equal("config", options[:config], "Expected config argument but not found.")
  end
end
