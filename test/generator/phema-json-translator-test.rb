require 'test_helper'
require 'json'

class PhenotypeJsonTranslatorTest < Minitest::Test
  def setup
    @translator = PhEMA::Phenotype::JsonTranslator.new
    # This example phenotype has one logical operator with two elements contained within
    @phenotype_string = '{"attrs":{"id":"mainLayer"},"id":3,"className":"Layer","children":[{"attrs":{"phemaObject":{"containedElements":[{"id":6},{"id":19}],"className":"LogicalOperator"},"draggable":true,"x":103,"y":96,"width":410,"height":178,"element":{"id":"And","name":"And","description":"The AND operator is used to conjoin two or more QDM elements or phrases that must all be true for the logic to hold. In the QDM, truth is determined by the existence of matching events (or the expected non-existence of such events). Note: The addition of any measure phrase should always be preceded by an AND or an OR.","uri":"http://rdf.healthit.gov/qdm/element#And","type":"LogicalOperator","children":[]}},"id":13,"className":"PhemaGroup","children":[{"attrs":{"width":410,"height":178,"fill":"#eeeeee","name":"mainRect","stroke":"gray","strokeWidth":1,"dash":[10,5]},"id":14,"className":"Rect"},{"attrs":{"width":410,"fontFamily":"Calibri","fontSize":14,"fill":"black","text":"And","name":"header","align":"center","padding":5,"height":"auto"},"id":15,"className":"Text"},{"attrs":{"connections":[],"y":89,"radius":7.5,"fill":"white","name":"leftConnector","stroke":"black","strokeWidth":1},"id":16,"className":"PhemaConnector"},{"attrs":{"connections":[],"x":410,"y":89,"radius":7.5,"fill":"white","name":"rightConnector","stroke":"black","strokeWidth":1},"id":17,"className":"PhemaConnector"},{"attrs":{"stroke":"gray","strokeWidth":1,"fill":"gray","x":403,"y":171,"width":7,"height":7,"name":"sizer"},"id":18,"className":"PhemaSizeBar"},{"attrs":{"phemaObject":{"className":"DataElement"},"draggable":true,"x":20,"y":44,"width":175,"height":114,"element":{"id":"PatientCareExperience","name":"Patient Care Experience","description":"Data elements that meet this criterion indicate the patient?s care experience, usually measured with a validated survey tool. The most common tool is the Consumer Assessment of Healthcare Providers and Systems.","uri":"http://rdf.healthit.gov/qdm/element#PatientCareExperience","type":"DataElement"}},"id":6,"className":"PhemaGroup","children":[{"attrs":{"width":175,"height":114,"fill":"#dbeef4","name":"mainRect","stroke":"black","strokeWidth":1},"id":7,"className":"Rect"},{"attrs":{"width":175,"fontFamily":"Calibri","fontSize":14,"fill":"black","text":"Patient Care Experience","name":"header","align":"center","padding":5,"height":"auto"},"id":8,"className":"Text"},{"attrs":{"x":10,"y":29,"width":155,"height":75,"fill":"#EEEEEE","name":"termDrop","stroke":"#CCCCCC","strokeWidth":1},"id":9,"className":"Rect"},{"attrs":{"x":10,"y":29,"width":155,"height":75,"fontFamily":"Calibri","fontSize":14,"fill":"gray","text":"Drag and drop clinical terms or value sets here, or click to search","align":"center","padding":5,"name":"termDropText"},"id":10,"className":"Text"},{"attrs":{"connections":[],"y":57,"radius":7.5,"fill":"white","name":"leftConnector","stroke":"black","strokeWidth":1},"id":11,"className":"PhemaConnector"},{"attrs":{"connections":[],"x":175,"y":57,"radius":7.5,"fill":"white","name":"rightConnector","stroke":"black","strokeWidth":1},"id":12,"className":"PhemaConnector"}]},{"attrs":{"phemaObject":{"className":"DataElement"},"draggable":true,"x":215,"y":44,"width":175,"height":114,"element":{"id":"CareGoal","name":"Care Goal","description":"Unlike other QDM datatypes, the Care Goal datatype does not indicate a specific context of use. Instead, to meet this criterion, there must be documentation of a care goal as defined by the Care Goal QDM category and its corresponding value set.","uri":"http://rdf.healthit.gov/qdm/element#CareGoal","type":"DataElement"}},"id":19,"className":"PhemaGroup","children":[{"attrs":{"width":175,"height":114,"fill":"#dbeef4","name":"mainRect","stroke":"black","strokeWidth":3},"id":20,"className":"Rect"},{"attrs":{"width":175,"fontFamily":"Calibri","fontSize":14,"fill":"black","text":"Care Goal","name":"header","align":"center","padding":5,"height":"auto"},"id":21,"className":"Text"},{"attrs":{"x":10,"y":29,"width":155,"height":75,"fill":"#EEEEEE","name":"termDrop","stroke":"#CCCCCC","strokeWidth":1},"id":22,"className":"Rect"},{"attrs":{"x":10,"y":29,"width":155,"height":75,"fontFamily":"Calibri","fontSize":14,"fill":"gray","text":"Drag and drop clinical terms or value sets here, or click to search","align":"center","padding":5,"name":"termDropText"},"id":23,"className":"Text"},{"attrs":{"connections":[],"y":57,"radius":7.5,"fill":"white","name":"leftConnector","stroke":"black","strokeWidth":1},"id":24,"className":"PhemaConnector"},{"attrs":{"connections":[],"x":175,"y":57,"radius":7.5,"fill":"white","name":"rightConnector","stroke":"black","strokeWidth":1},"id":25,"className":"PhemaConnector"}]}]}]}'
    @phenotype = JSON.parse(@phenotype_string)
  end

  def test_to_hds_invalid_json
    assert_raises(JSON::ParserError) { @translator.to_hds("test") }
  end

  def test_to_hds_valid_json
    @translator.to_hds(@phenotype_string)
  end

  def test_find_logical_operators
    operators = @translator.find_logical_operators(@phenotype)
    assert_equal 1, operators.length
  end

  def test_find_logical_operators_none_exist
    phenotype = JSON.parse("{}")
    operators = @translator.find_logical_operators(phenotype)
    assert_equal 0, operators.length

    phenotype = JSON.parse('{ "attrs": { "id": "mainLayer" }, "id": 3, "className": "Layer", "children": [ { "attrs": { "test": "test" } } ] }')
    operators = @translator.find_logical_operators(phenotype)
    assert_equal 0, operators.length
  end

  def test_build_id_element_map
    # The stock phenotype we use has a logical operator with two child items.  When that
    # is flattened out, we have 3 elements in total then that should be in the map.
    assert_equal 3, @translator.build_id_element_map(@phenotype).length
  end

  def test_build_logical_operators
    @translator.build_id_element_map(@phenotype)
    logical_operators = @translator.find_logical_operators(@phenotype)
    assert_equal 1, @translator.build_logical_operators(logical_operators).length
  end

  def test_build_logical_operators_elements_not_found
    # Here we have a logical operator that contains elements with IDs 6 and 19, neither of which
    # exist.  We expect it to still create the logical operator container.
    phenotype = JSON.parse('{ "id": 3, "className": "Layer", "children": [ { "attrs": { "phemaObject": { "containedElements": [ { "id": 6 }, { "id": 19 } ], "className": "LogicalOperator" }, "element": { "type": "LogicalOperator", "children": [] } }, "id": 13, "className": "PhemaGroup", "children": [] } ] }')
    @translator.build_id_element_map(phenotype)
    logical_operators = @translator.find_logical_operators(phenotype)
    assert_equal 1, @translator.build_logical_operators(logical_operators).length
  end
end