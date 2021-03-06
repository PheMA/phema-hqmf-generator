require 'test_helper'
require 'json'

class PhenotypeJsonTranslatorTest < Minitest::Unit::TestCase
  def setup
    @translator = PhEMA::Phenotype::JsonTranslator.new
    # This example phenotype has one logical operator with two elements contained within
    @phenotype_string = '{"attrs":{"id":"mainLayer"},"id":3,"className":"Layer","children":[{"attrs":{"phemaObject":{"containedElements":[{"id":6},{"id":19}],"className":"LogicalOperator"},"draggable":true,"x":103,"y":96,"width":410,"height":178,"element":{"id":"And","name":"And","description":"The AND operator is used to conjoin two or more QDM elements or phrases that must all be true for the logic to hold. In the QDM, truth is determined by the existence of matching events (or the expected non-existence of such events). Note: The addition of any measure phrase should always be preceded by an AND or an OR.","uri":"http://rdf.healthit.gov/qdm/element#And","type":"LogicalOperator","children":[]}},"id":13,"className":"PhemaGroup","children":[{"attrs":{"width":410,"height":178,"fill":"#eeeeee","name":"mainRect","stroke":"gray","strokeWidth":1,"dash":[10,5]},"id":14,"className":"Rect"},{"attrs":{"width":410,"fontFamily":"Calibri","fontSize":14,"fill":"black","text":"And","name":"header","align":"center","padding":5,"height":"auto"},"id":15,"className":"Text"},{"attrs":{"connections":[],"y":89,"radius":7.5,"fill":"white","name":"leftConnector","stroke":"black","strokeWidth":1},"id":16,"className":"PhemaConnector"},{"attrs":{"connections":[],"x":410,"y":89,"radius":7.5,"fill":"white","name":"rightConnector","stroke":"black","strokeWidth":1},"id":17,"className":"PhemaConnector"},{"attrs":{"stroke":"gray","strokeWidth":1,"fill":"gray","x":403,"y":171,"width":7,"height":7,"name":"sizer"},"id":18,"className":"PhemaSizeBar"},{"attrs":{"phemaObject":{"className":"DataElement"},"draggable":true,"x":20,"y":44,"width":175,"height":114,"element":{"id":"DiagnosisActive","name":"Diagnosis, Active","description":"Active diagnosis","uri":"http://rdf.healthit.gov/qdm/element#DiagnosisActive","type":"DataElement"}},"id":6,"className":"PhemaGroup","children":[{"attrs":{"width":175,"height":114,"fill":"#dbeef4","name":"mainRect","stroke":"black","strokeWidth":1},"id":7,"className":"Rect"},{"attrs":{"width":175,"fontFamily":"Calibri","fontSize":14,"fill":"black","text":"Diagnosis, Active","name":"header","align":"center","padding":5,"height":"auto"},"id":8,"className":"Text"},{"attrs":{"x":10,"y":29,"width":155,"height":75,"fill":"#EEEEEE","name":"termDrop","stroke":"#CCCCCC","strokeWidth":1},"id":9,"className":"Rect"},{"attrs":{"x":10,"y":29,"width":155,"height":75,"fontFamily":"Calibri","fontSize":14,"fill":"gray","text":"Drag and drop clinical terms or value sets here, or click to search","align":"center","padding":5,"name":"termDropText"},"id":10,"className":"Text"},{"attrs":{"connections":[],"y":57,"radius":7.5,"fill":"white","name":"leftConnector","stroke":"black","strokeWidth":1},"id":11,"className":"PhemaConnector"},{"attrs":{"connections":[],"x":175,"y":57,"radius":7.5,"fill":"white","name":"rightConnector","stroke":"black","strokeWidth":1},"id":12,"className":"PhemaConnector"}]},{"attrs":{"phemaObject":{"className":"DataElement"},"draggable":true,"x":215,"y":44,"width":175,"height":114,"element":{"id":"CareGoal","name":"Care Goal","description":"Unlike other QDM datatypes, the Care Goal datatype does not indicate a specific context of use. Instead, to meet this criterion, there must be documentation of a care goal as defined by the Care Goal QDM category and its corresponding value set.","uri":"http://rdf.healthit.gov/qdm/element#CareGoal","type":"DataElement"}},"id":19,"className":"PhemaGroup","children":[{"attrs":{"width":175,"height":114,"fill":"#dbeef4","name":"mainRect","stroke":"black","strokeWidth":3},"id":20,"className":"Rect"},{"attrs":{"width":175,"fontFamily":"Calibri","fontSize":14,"fill":"black","text":"Care Goal","name":"header","align":"center","padding":5,"height":"auto"},"id":21,"className":"Text"},{"attrs":{"x":10,"y":29,"width":155,"height":75,"fill":"#EEEEEE","name":"termDrop","stroke":"#CCCCCC","strokeWidth":1},"id":22,"className":"Rect"},{"attrs":{"x":10,"y":29,"width":155,"height":75,"fontFamily":"Calibri","fontSize":14,"fill":"gray","text":"Drag and drop clinical terms or value sets here, or click to search","align":"center","padding":5,"name":"termDropText"},"id":23,"className":"Text"},{"attrs":{"connections":[],"y":57,"radius":7.5,"fill":"white","name":"leftConnector","stroke":"black","strokeWidth":1},"id":24,"className":"PhemaConnector"},{"attrs":{"connections":[],"x":175,"y":57,"radius":7.5,"fill":"white","name":"rightConnector","stroke":"black","strokeWidth":1},"id":25,"className":"PhemaConnector"}]}]}]}'
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
    map = @translator.build_id_element_map(@phenotype)
    assert_equal 3, map.length

    # The elements in the map should have injected an "hds_name" key for all items, but only the two child items should have it defined
    assert_equal 2, map.select { |key, val| !val["hds_name"].nil? }.length
  end

  def test_build_logical_operators
    @translator.build_id_element_map(@phenotype)
    assert_equal 1, @translator.build_logical_operators(@phenotype).length

    # This other test uses a nested logical operator
    nested_logical_phenotype = JSON.parse('{"attrs":{"id":"mainLayer"},"id":3,"className":"Layer","children":[{"attrs":{"phemaObject":{"containedElements":[{"id":16}],"className":"LogicalOperator"},"draggable":true,"x":41,"y":56,"width":490,"height":201,"element":{"id":"Not","name":"Not","description":"The NOT operator is used to negate a QDM element or phrase when defining a population. In the QDM, negation asserts the non-existence of matching events for the QDM element or phrase. When an attribute is indicated for a QDM element in a negated phrase, what is being negated is the occurrence of a particular QDM element with that attribute.","uri":"http://rdf.healthit.gov/qdm/element#Not","type":"LogicalOperator","children":[]}},"id":32,"className":"PhemaGroup","children":[{"attrs":{"width":490,"height":201,"fill":"#eeeeee","name":"mainRect","stroke":"gray","strokeWidth":1,"dash":[10,5]},"id":33,"className":"Rect"},{"attrs":{"width":490,"fontFamily":"Calibri","fontSize":14,"fill":"black","text":"Not","name":"header","align":"center","padding":5,"height":"auto"},"id":34,"className":"Text"},{"attrs":{"connections":[],"y":100.5,"radius":7.5,"fill":"white","name":"leftConnector","stroke":"black","strokeWidth":1},"id":35,"className":"PhemaConnector"},{"attrs":{"connections":[],"x":490,"y":100.5,"radius":7.5,"fill":"white","name":"rightConnector","stroke":"black","strokeWidth":1},"id":36,"className":"PhemaConnector"},{"attrs":{"stroke":"gray","strokeWidth":1,"fill":"gray","x":483,"y":194,"width":7,"height":7,"name":"sizer"},"id":37,"className":"PhemaSizeBar"},{"attrs":{"phemaObject":{"containedElements":[{"id":22},{"id":6}],"className":"LogicalOperator"},"draggable":true,"x":20,"y":44,"width":450,"height":137,"element":{"id":"And","name":"And","description":"The AND operator is used to conjoin two or more QDM elements or phrases that must all be true for the logic to hold. In the QDM, truth is determined by the existence of matching events (or the expected non-existence of such events). Note: The addition of any measure phrase should always be preceded by an AND or an OR.","uri":"http://rdf.healthit.gov/qdm/element#And","type":"LogicalOperator","children":[]}},"id":16,"className":"PhemaGroup","children":[{"attrs":{"width":450,"height":137,"fill":"#eeeeee","name":"mainRect","stroke":"gray","strokeWidth":1,"dash":[10,5]},"id":17,"className":"Rect"},{"attrs":{"width":450,"fontFamily":"Calibri","fontSize":14,"fill":"black","text":"And","name":"header","align":"center","padding":5,"height":"auto"},"id":18,"className":"Text"},{"attrs":{"connections":[],"y":68.5,"radius":7.5,"fill":"white","name":"leftConnector","stroke":"black","strokeWidth":1},"id":19,"className":"PhemaConnector"},{"attrs":{"connections":[],"x":450,"y":68.5,"radius":7.5,"fill":"white","name":"rightConnector","stroke":"black","strokeWidth":1},"id":20,"className":"PhemaConnector"},{"attrs":{"stroke":"gray","strokeWidth":1,"fill":"gray","x":483,"y":194,"width":7,"height":7,"name":"sizer"},"id":21,"className":"PhemaSizeBar"},{"attrs":{"phemaObject":{"valueSet":{"id":29},"className":"DataElement"},"draggable":true,"x":20,"y":44,"width":195,"height":73,"element":{"id":"DiagnosisActive","name":"Diagnosis, Active","description":"To meet criteria using this datatype, the diagnosis indicated by the Condition/Diagnosis/Problem QDM category and its corresponding value set should reflect documentation of an active diagnosis. Keep in mind that when this datatype is used with timing relationships, the criterion is looking for an active diagnosis for the time frame indicated by the timing relationships.","uri":"http://rdf.healthit.gov/qdm/element#DiagnosisActive","type":"DataElement"}},"id":22,"className":"PhemaGroup","children":[{"attrs":{"width":195,"height":73,"fill":"#dbeef4","name":"mainRect","stroke":"black","strokeWidth":1},"id":23,"className":"Rect"},{"attrs":{"width":195,"fontFamily":"Calibri","fontSize":14,"fill":"black","text":"Diagnosis, Active","name":"header","align":"center","padding":5,"height":"auto"},"id":24,"className":"Text"},{"attrs":{"x":10,"y":29,"width":175,"height":34,"fill":"#EEEEEE","name":"termDrop","stroke":"#CCCCCC","strokeWidth":1},"id":25,"className":"Rect"},{"attrs":{"x":10,"y":29,"width":175,"height":34,"fontFamily":"Calibri","fontSize":14,"fill":"gray","text":"Drag and drop clinical terms or value sets here, or click to search","align":"center","padding":5,"name":"termDropText"},"id":26,"className":"Text"},{"attrs":{"connections":[],"y":36.5,"radius":7.5,"fill":"white","name":"leftConnector","stroke":"black","strokeWidth":1},"id":27,"className":"PhemaConnector"},{"attrs":{"connections":[],"x":195,"y":36.5,"radius":7.5,"fill":"white","name":"rightConnector","stroke":"black","strokeWidth":1},"id":28,"className":"PhemaConnector"},{"attrs":{"phemaObject":{"className":"ValueSet"},"draggable":true,"x":10,"y":29,"width":175,"height":34,"element":{"id":"2.16.840.1.113883.3.464.1003.125.11.1007","name":"Dental Caries","uri":"urn:oid:2.16.840.1.113883.3.464.1003.125.11.1007/version/20140501","type":"ValueSet","loadDetailStatus":"success","description":"Code system(s) used: CPT\r\nCodes: (first 3 of 16)\r\n (43644) Laparoscopy, surgical, gastric restrictive procedure; with gastric bypass and Roux-en-Y gastroenterostomy (roux limb 150 cm or less)\r\n (43645) Laparoscopy, surgical, gastric restrictive procedure; with gastric bypass and small intestine reconstruction to limit absorption\r\n (43770) Laparoscopy, surgical, gastric restrictive procedure; placement of adjustable gastric restrictive device (eg, gastric band and subcutaneous port components)\r\n","codeSystems":["CPT"],"members":[{"codeset":"CPT","code":"43644","name":"Laparoscopy, surgical, gastric restrictive procedure; with gastric bypass and Roux-en-Y gastroenterostomy (roux limb 150 cm or less)","uri":"http://id.nlm.nih.gov/cui/C1140095/43644","type":"Term","$$hashKey":"object:749"},{"codeset":"CPT","code":"43645","name":"Laparoscopy, surgical, gastric restrictive procedure; with gastric bypass and small intestine reconstruction to limit absorption","uri":"http://id.nlm.nih.gov/cui/C1140095/43645","type":"Term","$$hashKey":"object:750"},{"codeset":"CPT","code":"43770","name":"Laparoscopy, surgical, gastric restrictive procedure; placement of adjustable gastric restrictive device (eg, gastric band and subcutaneous port components)","uri":"http://id.nlm.nih.gov/cui/C1140095/43770","type":"Term","$$hashKey":"object:751"},{"codeset":"CPT","code":"43771","name":"Laparoscopy, surgical, gastric restrictive procedure; revision of adjustable gastric restrictive device component only","uri":"http://id.nlm.nih.gov/cui/C1140095/43771","type":"Term","$$hashKey":"object:752"},{"codeset":"CPT","code":"43772","name":"Laparoscopy, surgical, gastric restrictive procedure; removal of adjustable gastric restrictive device component only","uri":"http://id.nlm.nih.gov/cui/C1140095/43772","type":"Term","$$hashKey":"object:753"},{"codeset":"CPT","code":"43773","name":"Laparoscopy, surgical, gastric restrictive procedure; removal and replacement of adjustable gastric restrictive device component only","uri":"http://id.nlm.nih.gov/cui/C1140095/43773","type":"Term","$$hashKey":"object:754"},{"codeset":"CPT","code":"43774","name":"Laparoscopy, surgical, gastric restrictive procedure; removal of adjustable gastric restrictive device and subcutaneous port components","uri":"http://id.nlm.nih.gov/cui/C1140095/43774","type":"Term","$$hashKey":"object:755"},{"codeset":"CPT","code":"43842","name":"Gastric restrictive procedure, without gastric bypass, for morbid obesity; vertical-banded gastroplasty","uri":"http://id.nlm.nih.gov/cui/C1140095/43842","type":"Term","$$hashKey":"object:756"},{"codeset":"CPT","code":"43843","name":"Gastric restrictive procedure, without gastric bypass, for morbid obesity; other than vertical-banded gastroplasty","uri":"http://id.nlm.nih.gov/cui/C1140095/43843","type":"Term","$$hashKey":"object:757"},{"codeset":"CPT","code":"43845","name":"Gastric restrictive procedure with partial gastrectomy, pylorus-preserving duodenoileostomy and ileoileostomy (50 to 100 cm common channel) to limit absorption (biliopancreatic diversion with duodenal switch)","uri":"http://id.nlm.nih.gov/cui/C1140095/43845","type":"Term","$$hashKey":"object:758"},{"codeset":"CPT","code":"43846","name":"Gastric restrictive procedure, with gastric bypass for morbid obesity; with short limb (150 cm or less) Roux-en-Y gastroenterostomy","uri":"http://id.nlm.nih.gov/cui/C1140095/43846","type":"Term","$$hashKey":"object:759"},{"codeset":"CPT","code":"43847","name":"Gastric restrictive procedure, with gastric bypass for morbid obesity; with small intestine reconstruction to limit absorption","uri":"http://id.nlm.nih.gov/cui/C1140095/43847","type":"Term","$$hashKey":"object:760"},{"codeset":"CPT","code":"43848","name":"Revision, open, of gastric restrictive procedure for morbid obesity, other than adjustable gastric restrictive device (separate procedure)","uri":"http://id.nlm.nih.gov/cui/C1140095/43848","type":"Term","$$hashKey":"object:761"},{"codeset":"CPT","code":"97804","name":"Medical nutrition therapy; group (2 or more individual(s)), each 30 minutes","uri":"http://id.nlm.nih.gov/cui/C1140095/97804","type":"Term","$$hashKey":"object:762"},{"codeset":"CPT","code":"98960","name":"Education and training for patient self-management by a qualified, nonphysician health care professional using a standardized curriculum, face-to-face with the patient (could include caregiver/family) each 30 minutes; individual patient","uri":"http://id.nlm.nih.gov/cui/C1140095/98960","type":"Term","$$hashKey":"object:763"},{"codeset":"CPT","code":"99078","name":"Physician or other qualified health care professional qualified by education, training, licensure/regulation (when applicable) educational services rendered to patients in a group setting (eg, prenatal, obesity, or diabetic instructions)","uri":"http://id.nlm.nih.gov/cui/C1140095/99078","type":"Term","$$hashKey":"object:764"}],"$$hashKey":"object:661"}},"id":29,"className":"PhemaGroup","children":[{"attrs":{"width":175,"height":34,"fill":"#eedbf4","name":"mainRect","stroke":"black","strokeWidth":1},"id":30,"className":"Rect"},{"attrs":{"width":175,"fontFamily":"Calibri","fontSize":14,"fill":"black","text":"Dental Caries","name":"header","align":"center","padding":5,"height":"auto"},"id":31,"className":"Text"}]}]},{"attrs":{"phemaObject":{"valueSet":{"id":13},"attributes":{"PatientPreference":[],"Ordinality":[],"ProviderPreference":[],"NegationRationale":[],"Severity":[],"AnatomicalLocationSite":[],"HealthRecordField":[],"Source":[],"Recorder":[],"Result":{"valueSet":[]},"Dose":{"valueSet":[]}},"className":"DataElement"},"draggable":true,"x":235,"y":44,"width":195,"height":73,"element":{"id":"DiagnosisActive","name":"Diagnosis, Active","description":"To meet criteria using this datatype, the diagnosis indicated by the Condition/Diagnosis/Problem QDM category and its corresponding value set should reflect documentation of an active diagnosis. Keep in mind that when this datatype is used with timing relationships, the criterion is looking for an active diagnosis for the time frame indicated by the timing relationships.","uri":"http://rdf.healthit.gov/qdm/element#DiagnosisActive","type":"DataElement"}},"id":6,"className":"PhemaGroup","children":[{"attrs":{"width":195,"height":73,"fill":"#dbeef4","name":"mainRect","stroke":"black","strokeWidth":1},"id":7,"className":"Rect"},{"attrs":{"width":195,"fontFamily":"Calibri","fontSize":14,"fill":"black","text":"Diagnosis, Active","name":"header","align":"center","padding":5,"height":"auto"},"id":8,"className":"Text"},{"attrs":{"x":10,"y":29,"width":175,"height":34,"fill":"#EEEEEE","name":"termDrop","stroke":"#CCCCCC","strokeWidth":1},"id":9,"className":"Rect"},{"attrs":{"x":10,"y":29,"width":175,"height":34,"fontFamily":"Calibri","fontSize":14,"fill":"gray","text":"Drag and drop clinical terms or value sets here, or click to search","align":"center","padding":5,"name":"termDropText"},"id":10,"className":"Text"},{"attrs":{"connections":[],"y":36.5,"radius":7.5,"fill":"white","name":"leftConnector","stroke":"black","strokeWidth":1},"id":11,"className":"PhemaConnector"},{"attrs":{"connections":[],"x":195,"y":36.5,"radius":7.5,"fill":"white","name":"rightConnector","stroke":"black","strokeWidth":1},"id":12,"className":"PhemaConnector"},{"attrs":{"phemaObject":{"className":"ValueSet"},"draggable":true,"x":10,"y":29,"width":175,"height":34,"element":{"id":"2.16.840.1.113883.3.464.1003.199.11.1005","name":"Acute Lymphadenitis","uri":"urn:oid:2.16.840.1.113883.3.464.1003.199.11.1005/version/20140501","type":"ValueSet","loadDetailStatus":"success","description":"Code system(s) used: CPT\r\nCodes: (first 3 of 16)\r\n (43644) Laparoscopy, surgical, gastric restrictive procedure; with gastric bypass and Roux-en-Y gastroenterostomy (roux limb 150 cm or less)\r\n (43645) Laparoscopy, surgical, gastric restrictive procedure; with gastric bypass and small intestine reconstruction to limit absorption\r\n (43770) Laparoscopy, surgical, gastric restrictive procedure; placement of adjustable gastric restrictive device (eg, gastric band and subcutaneous port components)\r\n","codeSystems":["CPT"],"members":[{"codeset":"CPT","code":"43644","name":"Laparoscopy, surgical, gastric restrictive procedure; with gastric bypass and Roux-en-Y gastroenterostomy (roux limb 150 cm or less)","uri":"http://id.nlm.nih.gov/cui/C1140095/43644","type":"Term","$$hashKey":"object:584"},{"codeset":"CPT","code":"43645","name":"Laparoscopy, surgical, gastric restrictive procedure; with gastric bypass and small intestine reconstruction to limit absorption","uri":"http://id.nlm.nih.gov/cui/C1140095/43645","type":"Term","$$hashKey":"object:585"},{"codeset":"CPT","code":"43770","name":"Laparoscopy, surgical, gastric restrictive procedure; placement of adjustable gastric restrictive device (eg, gastric band and subcutaneous port components)","uri":"http://id.nlm.nih.gov/cui/C1140095/43770","type":"Term","$$hashKey":"object:586"},{"codeset":"CPT","code":"43771","name":"Laparoscopy, surgical, gastric restrictive procedure; revision of adjustable gastric restrictive device component only","uri":"http://id.nlm.nih.gov/cui/C1140095/43771","type":"Term","$$hashKey":"object:587"},{"codeset":"CPT","code":"43772","name":"Laparoscopy, surgical, gastric restrictive procedure; removal of adjustable gastric restrictive device component only","uri":"http://id.nlm.nih.gov/cui/C1140095/43772","type":"Term","$$hashKey":"object:588"},{"codeset":"CPT","code":"43773","name":"Laparoscopy, surgical, gastric restrictive procedure; removal and replacement of adjustable gastric restrictive device component only","uri":"http://id.nlm.nih.gov/cui/C1140095/43773","type":"Term","$$hashKey":"object:589"},{"codeset":"CPT","code":"43774","name":"Laparoscopy, surgical, gastric restrictive procedure; removal of adjustable gastric restrictive device and subcutaneous port components","uri":"http://id.nlm.nih.gov/cui/C1140095/43774","type":"Term","$$hashKey":"object:590"},{"codeset":"CPT","code":"43842","name":"Gastric restrictive procedure, without gastric bypass, for morbid obesity; vertical-banded gastroplasty","uri":"http://id.nlm.nih.gov/cui/C1140095/43842","type":"Term","$$hashKey":"object:591"},{"codeset":"CPT","code":"43843","name":"Gastric restrictive procedure, without gastric bypass, for morbid obesity; other than vertical-banded gastroplasty","uri":"http://id.nlm.nih.gov/cui/C1140095/43843","type":"Term","$$hashKey":"object:592"},{"codeset":"CPT","code":"43845","name":"Gastric restrictive procedure with partial gastrectomy, pylorus-preserving duodenoileostomy and ileoileostomy (50 to 100 cm common channel) to limit absorption (biliopancreatic diversion with duodenal switch)","uri":"http://id.nlm.nih.gov/cui/C1140095/43845","type":"Term","$$hashKey":"object:593"},{"codeset":"CPT","code":"43846","name":"Gastric restrictive procedure, with gastric bypass for morbid obesity; with short limb (150 cm or less) Roux-en-Y gastroenterostomy","uri":"http://id.nlm.nih.gov/cui/C1140095/43846","type":"Term","$$hashKey":"object:594"},{"codeset":"CPT","code":"43847","name":"Gastric restrictive procedure, with gastric bypass for morbid obesity; with small intestine reconstruction to limit absorption","uri":"http://id.nlm.nih.gov/cui/C1140095/43847","type":"Term","$$hashKey":"object:595"},{"codeset":"CPT","code":"43848","name":"Revision, open, of gastric restrictive procedure for morbid obesity, other than adjustable gastric restrictive device (separate procedure)","uri":"http://id.nlm.nih.gov/cui/C1140095/43848","type":"Term","$$hashKey":"object:596"},{"codeset":"CPT","code":"97804","name":"Medical nutrition therapy; group (2 or more individual(s)), each 30 minutes","uri":"http://id.nlm.nih.gov/cui/C1140095/97804","type":"Term","$$hashKey":"object:597"},{"codeset":"CPT","code":"98960","name":"Education and training for patient self-management by a qualified, nonphysician health care professional using a standardized curriculum, face-to-face with the patient (could include caregiver/family) each 30 minutes; individual patient","uri":"http://id.nlm.nih.gov/cui/C1140095/98960","type":"Term","$$hashKey":"object:598"},{"codeset":"CPT","code":"99078","name":"Physician or other qualified health care professional qualified by education, training, licensure/regulation (when applicable) educational services rendered to patients in a group setting (eg, prenatal, obesity, or diabetic instructions)","uri":"http://id.nlm.nih.gov/cui/C1140095/99078","type":"Term","$$hashKey":"object:599"}],"$$hashKey":"object:485"}},"id":13,"className":"PhemaGroup","children":[{"attrs":{"width":175,"height":34,"fill":"#eedbf4","name":"mainRect","stroke":"black","strokeWidth":1},"id":14,"className":"Rect"},{"attrs":{"width":175,"fontFamily":"Calibri","fontSize":14,"fill":"black","text":"Acute Lymphadenitis","name":"header","align":"center","padding":5,"height":"auto"},"id":15,"className":"Text"}]}]}]}]}]}')
    @translator.build_id_element_map(nested_logical_phenotype)
    logical_operators = @translator.build_logical_operators(nested_logical_phenotype)
    assert_equal 1, logical_operators.length
    assert_equal 2, logical_operators[0]["preconditions"][0]["preconditions"].length

    # No logical operators explicitly defined
    no_logical_operators = JSON.parse('{"attrs":{"id":"mainLayer"},"id":3,"className":"Layer","children":[{"attrs":{"phemaObject":{"attributes":{"PatientPreference":[],"Ordinality":[],"ProviderPreference":[],"NegationRationale":[],"Severity":[],"AnatomicalLocationSite":[],"HealthRecordField":[],"Source":[],"Recorder":[],"Result":{"valueSet":[],"type":"present"},"Dose":{"valueSet":[]}},"className":"DataElement"},"draggable":true,"x":235,"y":153,"width":175,"height":114,"element":{"id":"LaboratoryTestOrder","name":"Laboratory Test, Order","description":"Data elements that meet criteria using this datatype should document a request for the laboratory test indicated by the QDM category and its corresponding value set.","uri":"http://rdf.healthit.gov/qdm/element#LaboratoryTestOrder","type":"DataElement"}},"id":6,"className":"PhemaGroup","children":[{"attrs":{"width":175,"height":114,"fill":"#dbeef4","name":"mainRect","stroke":"black","strokeWidth":3},"id":7,"className":"Rect"},{"attrs":{"width":175,"fontFamily":"Calibri","fontSize":14,"fill":"black","text":"Laboratory Test, Order","name":"header","align":"center","padding":5,"height":"auto"},"id":8,"className":"Text"},{"attrs":{"x":10,"y":29,"width":155,"height":75,"fill":"#EEEEEE","name":"termDrop","stroke":"#CCCCCC","strokeWidth":1},"id":9,"className":"Rect"},{"attrs":{"x":10,"y":29,"width":155,"height":75,"fontFamily":"Calibri","fontSize":14,"fill":"gray","text":"Drag and drop clinical terms or value sets here, or click to search","align":"center","padding":5,"name":"termDropText"},"id":10,"className":"Text"},{"attrs":{"connections":[],"y":57,"radius":7.5,"fill":"white","name":"leftConnector","stroke":"black","strokeWidth":1},"id":11,"className":"PhemaConnector"},{"attrs":{"connections":[],"x":175,"y":57,"radius":7.5,"fill":"white","name":"rightConnector","stroke":"black","strokeWidth":1},"id":12,"className":"PhemaConnector"}]}]}')
    @translator.build_id_element_map(no_logical_operators)
    assert_equal 1, @translator.build_logical_operators(no_logical_operators).length
  end

  def test_build_logical_operators_elements_not_found
    # Here we have a logical operator that contains elements with IDs 6 and 19, neither of which
    # exist.  We expect it to still create the logical operator container.
    phenotype = JSON.parse('{ "id": 3, "className": "Layer", "children": [ { "attrs": { "phemaObject": { "containedElements": [ { "id": 6 }, { "id": 19 } ], "className": "LogicalOperator" }, "element": { "type": "LogicalOperator", "children": [] } }, "id": 13, "className": "PhemaGroup", "children": [] } ] }')
    @translator.build_id_element_map(phenotype)
    assert_equal 1, @translator.build_logical_operators(@phenotype).length
  end

  def test_build_attributes_for_element
    element_without_attrs = JSON.parse('{"attrs":{"id":"mainLayer"},"id":3,"className":"Layer","children":[{"attrs":{"phemaObject":{"valueSet":{"id":13},"className":"DataElement"},"draggable":true,"x":50,"y":50,"width":195,"height":73,"element":{"id":"DiagnosisActive","name":"Diagnosis, Active","uri":"http://rdf.healthit.gov/qdm/element#DiagnosisActive","type":"DataElement"}},"id":6,"className":"PhemaGroup","children":[{"attrs":{"phemaObject":{"className":"ValueSet"},"element":{"id":"2.16.840.1.113883.3.600.1.1523","name":"Above Normal f/u icd 10","uri":"urn:oid:2.16.840.1.113883.3.600.1.1523/version/20140501","type":"ValueSet","loadDetailStatus":"success"}},"id":13,"className":"PhemaGroup","children":[{"attrs":{"width":175,"height":34,"fill":"#eedbf4","name":"mainRect","stroke":"black","strokeWidth":1},"id":14,"className":"Rect"}]}]}]}')
    assert_equal nil, @translator.build_attributes_for_element(element_without_attrs)

    element_with_attrs = JSON.parse('{"attrs":{"phemaObject":{"valueSet":{"id":13},"attributes":{"PatientPreference":[],"Ordinality":[{"id":"2.16.840.1.113883.3.464.1003.101.11.1040","name":"Outpatient Consultation","uri":"urn:oid:2.16.840.1.113883.3.464.1003.101.11.1040/version/20140501","type":"ValueSet","loadDetailStatus":"success"}],"ProviderPreference":[],"NegationRationale":[],"Severity":[],"AnatomicalLocationSite":[],"HealthRecordField":[],"Source":[],"Recorder":[],"Result":{"valueSet":[],"type":"present"},"Dose":{"valueSet":[],"type":"present"}},"className":"DataElement"},"draggable":true,"x":50,"y":50,"width":195,"height":73,"element":{"id":"DiagnosisActive","name":"Diagnosis, Active","uri":"http://rdf.healthit.gov/qdm/element#DiagnosisActive","type":"DataElement"}},"id":6,"className":"PhemaGroup","children":[{"attrs":{"phemaObject":{"className":"ValueSet"},"element":{"id":"2.16.840.1.113883.3.600.1.1523","name":"Above Normal f/u icd 10","uri":"urn:oid:2.16.840.1.113883.3.600.1.1523/version/20140501","type":"ValueSet","loadDetailStatus":"success"}},"id":13,"className":"PhemaGroup","children":[{"attrs":{"width":175,"height":34,"fill":"#eedbf4","name":"mainRect","stroke":"black","strokeWidth":1},"id":14,"className":"Rect"}]}]}')
    attributes = @translator.build_attributes_for_element(element_with_attrs)
    assert_equal 2, attributes.length  #All that comes out are attributes with defined values, with the result attribute removed

    # Test for value ranges, comparisons and direct equal
  end

  def assert_range type_expected, type_actual, low_val_expected, low_val_actual, high_val_expected, high_val_actual, units_expected, low_units_actual, high_units_actual
    assert_equal type_expected, type_actual
    assert_equal low_val_expected, low_val_actual
    if low_val_expected.nil?
      assert_equal nil, low_units_actual
    else
      assert_equal units_expected, low_units_actual
    end
    assert_equal high_val_expected, high_val_actual
    if high_val_expected.nil?
      assert_equal nil, high_units_actual
    else
      assert_equal units_expected, high_units_actual
    end
  end

  def test_build_range_hash_between
    range = @translator.build_range_hash false, "BW", "cm", 5, 10
    assert_range "IVL_PQ", range["type"], 5, range["low"]["value"], 10, range["high"]["value"], "cm", range["low"]["unit"], range["high"]["unit"]
    range = @translator.build_range_hash false, "between", "cm", 5, 10
    assert_range "IVL_PQ", range["type"], 5, range["low"]["value"], 10, range["high"]["value"], "cm", range["low"]["unit"], range["high"]["unit"]
  end

  def test_build_range_hash_equal
    range = @translator.build_range_hash false, "EQ", "cm", 5
    assert_range "IVL_PQ", range["type"], 5, range["low"]["value"], 5, range["high"]["value"], "cm", range["low"]["unit"], range["high"]["unit"]
    range = @translator.build_range_hash false, "exactly", "cm", 5
    assert_range "IVL_PQ", range["type"], 5, range["low"]["value"], 5, range["high"]["value"], "cm", range["low"]["unit"], range["high"]["unit"]
  end

  def test_build_range_hash_less_than
    range = @translator.build_range_hash false, "LT", "cm", 5
    assert_range "IVL_PQ", range["type"], nil, range["low"], 5, range["high"]["value"], "cm", range["low"], range["high"]["unit"]
    range = @translator.build_range_hash false, "<", "cm", 5
    assert_range "IVL_PQ", range["type"], nil, range["low"], 5, range["high"]["value"], "cm", range["low"], range["high"]["unit"]
  end

  def test_build_range_hash_greater_than
    range = @translator.build_range_hash false, "GT", "cm", 5
    assert_range "IVL_PQ", range["type"], 5, range["low"]["value"], nil, range["high"], "cm", range["low"]["unit"], range["high"]
    range = @translator.build_range_hash false, ">", "cm", 5
    assert_range "IVL_PQ", range["type"], 5, range["low"]["value"], nil, range["high"], "cm", range["low"]["unit"], range["high"]
  end

  def test_build_range_hash_unknown_operator
    range = @translator.build_range_hash false, "BLAH", "cm", 5
    assert_equal true, range.empty?
  end

  def test_set_phenotype_metadata
    phenotype = JSON.parse('{"attrs":{"id":"mainLayer","phenotypeData":{"id":"1234567","name":"Test phenotype","description":"test phenotype description"}},"id":3,"className":"Layer","children":[]}')
    measure = @translator.set_phenotype_metadata(phenotype, {})
    assert_equal "Test phenotype", measure["title"]
    assert_equal "test phenotype description", measure["description"]
    assert_equal "1234567", measure["measure_id"]
    assert_equal "1234567", measure["hqmf_id"]
    assert_equal "1234567", measure["hqmf_set_id"]
  end

  def test_set_phenotype_metadata_when_empty
    phenotype = JSON.parse('{"attrs":{}}')
    measure = @translator.set_phenotype_metadata(phenotype, {})
    assert !measure["title"].empty?
    assert measure["description"].nil?
    assert !measure["measure_id"].empty?
    assert_equal measure["measure_id"], measure["hqmf_id"]
    assert !measure["hqmf_set_id"].empty?
    assert measure["measure_id"] != measure["hqmf_set_id"]
  end

  def test_build_value_for_element
    value_set = {"id" => "1.2.3", "name" => "Test"}
    range = {"type" => "value", "operator" => "exactly", "valueLow" => "100", "units" => {"id" => "mg"}}

    # Value set only
    value = @translator.build_value_for_element(value_set, nil)
    assert_equal "CD", value["type"]
    assert_equal "1.2.3", value["code_list_id"]
    assert_equal "Test", value["title"]

    # Value set and range - ignore value set
    value = @translator.build_value_for_element(value_set, range)
    assert_equal "IVL_PQ", value["type"]
    assert_equal nil, value["code_list_id"]
    assert_equal "100", value["low"]["value"]
    assert_equal "mg", value["low"]["unit"]

    # Nil value set - just making sure it doesn't crash & uses range
    value = @translator.build_value_for_element(nil, range)
    assert_equal "IVL_PQ", value["type"]

    # Look for presence of a value
    value = @translator.build_value_for_element(nil, {"type" => "present"})
    assert_equal "ANYNonNull", value["type"]
  end

  def test_get_result_attribute_for_element
    element = JSON.parse('{"attrs":{"phemaObject":{"attributes":{"PatientPreference":[],"Ordinality":[],"ProviderPreference":[],"NegationRationale":[],"Severity":[],"AnatomicalLocationSite":[],"HealthRecordField":[],"Source":[],"Recorder":[],"Result":{"valueSet":[],"type":"present"},"Dose":{"valueSet":[]}},"className":"DataElement"},"draggable":true,"x":235,"y":153,"width":175,"height":114,"element":{"id":"LaboratoryTestOrder","name":"Laboratory Test, Order","description":"Data elements that meet criteria using this datatype should document a request for the laboratory test indicated by the QDM category and its corresponding value set.","uri":"http://rdf.healthit.gov/qdm/element#LaboratoryTestOrder","type":"DataElement"}},"id":6,"className":"PhemaGroup","children":[{"attrs":{"width":175,"height":114,"fill":"#dbeef4","name":"mainRect","stroke":"black","strokeWidth":3},"id":7,"className":"Rect"},{"attrs":{"width":175,"fontFamily":"Calibri","fontSize":14,"fill":"black","text":"Laboratory Test, Order","name":"header","align":"center","padding":5,"height":"auto"},"id":8,"className":"Text"},{"attrs":{"x":10,"y":29,"width":155,"height":75,"fill":"#EEEEEE","name":"termDrop","stroke":"#CCCCCC","strokeWidth":1},"id":9,"className":"Rect"},{"attrs":{"x":10,"y":29,"width":155,"height":75,"fontFamily":"Calibri","fontSize":14,"fill":"gray","text":"Drag and drop clinical terms or value sets here, or click to search","align":"center","padding":5,"name":"termDropText"},"id":10,"className":"Text"},{"attrs":{"connections":[],"y":57,"radius":7.5,"fill":"white","name":"leftConnector","stroke":"black","strokeWidth":1},"id":11,"className":"PhemaConnector"},{"attrs":{"connections":[],"x":175,"y":57,"radius":7.5,"fill":"white","name":"rightConnector","stroke":"black","strokeWidth":1},"id":12,"className":"PhemaConnector"}]}')
    result = @translator.get_result_attribute_for_element(element)
    assert_equal "Result", result[0]
    assert_equal "present", result[1]["type"]
  end

  def test_get_value_set_for_element_when_empty
    element = JSON.parse('{"children": []}')
    result = @translator.get_value_set_for_element(element)
    assert_equal "", result["id"]
    assert_equal "(Not specified)", result["name"]
  end

  def test_get_value_set_for_element
    element = JSON.parse('{"children": [{"attrs": {"element": {"id": "1234", "name": "Test"}, "phemaObject": {"className":"ValueSet"}}}]}')
    result = @translator.get_value_set_for_element(element)
    assert_equal "1234", result["id"]
    assert_equal "Test", result["name"]
  end
end