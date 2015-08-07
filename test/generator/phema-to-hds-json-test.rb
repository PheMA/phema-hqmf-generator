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

  def test_measure_type
    result = PhEMA::HealthDataStandards::JsonTranslator.measure_type("PROCESS")
    assert_equal 'MSRTYPE', result["code_obj"]["code"]
    assert_equal 'PROCESS', result["value_obj"]["code"]
    assert_equal 'Process', result["value_obj"]["title"]

    result = PhEMA::HealthDataStandards::JsonTranslator.measure_type("UNKNOWN")
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
    assert_equal 'REF', result["code_obj"]["code"]
    assert_equal 'Reference', result["code_obj"]["title"]
  end

  def test_definition
    result = PhEMA::HealthDataStandards::JsonTranslator.definition('test')
    assert_equal 'DEF', result["code_obj"]["code"]
    assert_equal 'Definition', result["code_obj"]["title"]
  end

  def test_initial_population
    result = PhEMA::HealthDataStandards::JsonTranslator.initial_population('test')
    assert_equal 'IPOP', result["code_obj"]["code"]
    assert_equal 'Initial Population', result["code_obj"]["title"]
  end

  def test_text_attribute
    result = PhEMA::HealthDataStandards::JsonTranslator.text_attribute('TEST', 'Test', 'This is a test')
    assert_equal 'ED', result["code_obj"]["type"]
    assert_equal 'TEST', result["code_obj"]["code"]
    assert_equal 'Test', result["code_obj"]["title"]
    assert_equal 'This is a test', result["value_obj"]["value"]

    result = PhEMA::HealthDataStandards::JsonTranslator.text_attribute('A', 'A', nil)
    assert_equal '', result["value_obj"]["value"]

    result = PhEMA::HealthDataStandards::JsonTranslator.text_attribute('A', 'A', 'With some <html> tags & markup')
    assert_equal 'With some &lt;html&gt; tags &amp; markup', result["value_obj"]["value"]
  end

  def test_data_criteria
    result = PhEMA::HealthDataStandards::JsonTranslator.data_criteria('test', nil, nil, nil, false, false, nil)
    assert_equal nil, result

    result = PhEMA::HealthDataStandards::JsonTranslator.data_criteria(
      "http://rdf.healthit.gov/qdm/element#DeviceAllergy",
      { :code => "1.2.3", :title => "Value set test" },
      { :severity => {:code => "2.3.4", :title => "Severity test" } },
      nil, false, false, "A" )
    assert_equal '1.2.3', result["value"]["code_list_id"]
    assert_equal 'device_allergy', result["definition"]
    assert_equal 'Device, Allergy', result["description"]
    assert_equal false, result["hard_status"]
    assert_equal false, result["negation"]
    assert_equal 'A', result["source_data_criteria"]
    assert_equal '', result["status"]
    assert_equal '', result["type"]
    assert_equal false, result["variable"]
    assert_equal 1, result["field_values"].length
    assert_equal '2.3.4', result["field_values"]["SEVERITY"]["code_list_id"]

    result = PhEMA::HealthDataStandards::JsonTranslator.data_criteria(
      "http://rdf.healthit.gov/qdm/element#DeviceAllergy",
      { :code => "1.2.3", :title => "Value set test" },
      { :ordinal => {:code => "2.3.4" } },
      nil, false, false, "A" )
    assert_equal 1, result["field_values"].length
    assert_equal '2.3.4', result["field_values"]["ORDINAL"]["code_list_id"]

    # Can handle when no attributes are specified
    result = PhEMA::HealthDataStandards::JsonTranslator.data_criteria(
      "http://rdf.healthit.gov/qdm/element#DeviceAllergy",
      { :code => "1.2.3", :title => "Value set test" }, nil, nil, false, false, "A" )
    assert_equal 0, result["field_values"].length
  end

  def test_severity
    result = PhEMA::HealthDataStandards::JsonTranslator.severity(nil, 'test title')
    assert_equal nil, result

    result = PhEMA::HealthDataStandards::JsonTranslator.severity('1.2.3', 'test title')
    assert_equal 'CD', result['type']
    assert_equal '1.2.3', result['code_list_id']
    assert_equal 'test title', result['title']
  end
end