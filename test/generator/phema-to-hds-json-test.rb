require 'test_helper'

class JsonTranslatorTest < MiniTest::Unit::TestCase
  def setup
  end

  def test_measure_score
    result = PhEMA::HealthDataStandards::JsonTranslator.measure_score("COHORT")
    assert_equal 'MSRSCORE', result["code_obj"]["code"]
    assert_equal 'COHORT', result["value_obj"]["code"]
    assert_equal 'Cohort', result["value_obj"]["title"]

    result = PhEMA::HealthDataStandards::JsonTranslator.measure_score("UNKNOWN")
    assert_equal 'UNKNOWN', result["value_obj"]["code"]
    assert_equal 'UNKNOWN', result["value_obj"]["title"]
  end

  def test_measure_period
    result = PhEMA::HealthDataStandards::JsonTranslator.measure_period(nil, nil)
    assert_equal '19000101', result["low"]["value"]
    assert_equal Time.now.strftime("%Y%m%d"), result["high"]["value"]

    result = PhEMA::HealthDataStandards::JsonTranslator.measure_period("20140101", "20141231")
    assert_equal '20140101', result["low"]["value"]
    assert_equal '20141231', result["high"]["value"]
  end

  def test_reference
    result = PhEMA::HealthDataStandards::JsonTranslator.reference('test')
    assert_equal 'ED', result["code_obj"]["type"]
    assert_equal 'test', result["value_obj"]["value"]

    result = PhEMA::HealthDataStandards::JsonTranslator.reference(nil)
    assert_equal '', result["value_obj"]["value"]

    result = PhEMA::HealthDataStandards::JsonTranslator.reference('With some <html> tags & markup')
    assert_equal 'With some &lt;html&gt; tags &amp; markup', result["value_obj"]["value"]
  end
end