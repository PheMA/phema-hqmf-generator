module PhEMA
  module HealthDataStandards
    QDM_HQMF_MAPPING = [
      { :id => "http://rdf.healthit.gov/qdm/element#CareGoal", :name => "CareGoal", :description => "Care Goal", :type => "", :definition => "care_goal", :status => "", :code => { "HL7 Act Code" => [ "ASSERTION" ] } },

      { :id => "http://rdf.healthit.gov/qdm/element#CommunicationFromPatienttoProvider", :name => "CommunicationFromPatienttoProvider", :description => "Communication, From Patient to Provider", :type => "", :definition => "communication_from_patient_to_provider", :status => "" },
      { :id => "http://rdf.healthit.gov/qdm/element#CommunicationFromProvidertoPatient", :name => "CommunicationFromProvidertoPatient", :description => "Communication, From Provider to Patient", :type => "", :definition => "communication_from_provider_to_patient", :status => "" },
      { :id => "http://rdf.healthit.gov/qdm/element#CommunicationFromProvidertoProvider", :name => "CommunicationFromProvidertoProvider", :description => "Communication, From Provider to Provider", :type => "", :definition => "communication_from_provider_to_provider", :status => "" },

      { :id => "http://rdf.healthit.gov/qdm/element#DeviceAdverseEvent", :name => "DeviceAdverseEvent", :description => "Device, Adverse Event", :type => "", :definition => "device_adverse_event", :status => "", :code => { "HL7 Act Code" => [ "ASSERTION" ] } },
      { :id => "http://rdf.healthit.gov/qdm/element#DeviceAllergy", :name => "DeviceAllergy", :description => "Device, Allergy", :type => "", :definition => "device_allergy", :status => "", :code => { "HL7 Act Code" => [ "ASSERTION" ] } },
      { :id => "http://rdf.healthit.gov/qdm/element#DeviceApplied", :name => "DeviceApplied", :description => "Device, Applied", :type => "", :definition => "device", :status => "applied", :code => { "SNOMED-CT" => [ "360030002" ] } },
      { :id => "http://rdf.healthit.gov/qdm/element#DeviceIntolerance", :name => "DeviceIntolerance", :description => "Device, Intolerance", :type => "", :definition => "device_intolerance", :status => "", :code => { "HL7 Act Code" => [ "ASSERTION" ] } },
      { :id => "http://rdf.healthit.gov/qdm/element#DeviceOrder", :name => "DeviceOrder", :description => "Device, Order", :type => "", :definition => "device", :status => "ordered" },
      { :id => "http://rdf.healthit.gov/qdm/element#DeviceRecommended", :name => "DeviceRecommended", :description => "Device, Recommended", :type => "", :definition => "device", :status => "recommended" },

      { :id => "http://rdf.healthit.gov/qdm/element#DiagnosisActive", :name => "DiagnosisActive", :description => "Diagnosis, Active", :type => "conditions", :definition => "diagnosis", :status => "active", :code => { "SNOMED-CT" => [ "282291009" ] } },
      { :id => "http://rdf.healthit.gov/qdm/element#DiagnosisFamilyHistory", :name => "DiagnosisFamilyHistory", :description => "Diagnosis, Family History", :type => "conditions", :definition => "diagnosis", :status => "family_history", :code => { "HL7 Act Code" => [ "10157-6" ] } },
      { :id => "http://rdf.healthit.gov/qdm/element#DiagnosisInactive", :name => "DiagnosisInactive", :description => "Diagnosis, Inactive", :type => "conditions", :definition => "diagnosis", :status => "inactive", :code => { "SNOMED-CT" => [ "282291009" ] } },
      { :id => "http://rdf.healthit.gov/qdm/element#DiagnosisResolved", :name => "DiagnosisResolved", :description => "Diagnosis, Resolved", :type => "conditions", :definition => "diagnosis", :status => "resolved", :code => { "SNOMED-CT" => [ "282291009" ] } },

      { :id => "http://rdf.healthit.gov/qdm/element#DiagnosticStudyAdverseEvent", :name => "DiagnosticStudyAdverseEvent", :description => "Diagnostic Study, Adverse Event", :type => "", :definition => "diagnostic_study_adverse_event", :status => "", :code => { "HL7 Act Code" => [ "ASSERTION" ] } },
      { :id => "http://rdf.healthit.gov/qdm/element#DiagnosticStudyIntolerance", :name => "DiagnosticStudyIntolerance", :description => "Diagnostic Study, Intolerance", :type => "", :definition => "diagnostic_study_intolerance", :status => "", :code => { "HL7 Act Code" => [ "ASSERTION" ] } },
      { :id => "http://rdf.healthit.gov/qdm/element#DiagnosticStudyOrder", :name => "DiagnosticStudyOrder", :description => "Diagnostic Study, Order", :type => "", :definition => "diagnostic_study", :status => "ordered" },
      { :id => "http://rdf.healthit.gov/qdm/element#DiagnosticStudyPerformed", :name => "DiagnosticStudyPerformed", :description => "Diagnostic Study, Performed", :type => "", :definition => "diagnostic_study", :status => "performed" },
      { :id => "http://rdf.healthit.gov/qdm/element#DiagnosticStudyRecommended", :name => "DiagnosticStudyRecommended", :description => "Diagnostic Study, Recommended", :type => "", :definition => "diagnostic_study", :status => "recommended" },

      { :id => "http://rdf.healthit.gov/qdm/element#EncounterActive", :name => "EncounterActive", :description => "Encounter, Active", :type => "encounters", :definition => "encounter", :status => "active" },
      { :id => "http://rdf.healthit.gov/qdm/element#EncounterOrder", :name => "EncounterOrder", :name => "Encounter, Order", :type => "encounters", :definition => "encounter", :status => "ordered" },
      { :id => "http://rdf.healthit.gov/qdm/element#EncounterPerformed", :name => "EncounterPerformed", :description => "Encounter, Performed", :type => "encounters", :definition => "encounter", :status => "performed" },
      { :id => "http://rdf.healthit.gov/qdm/element#EncounterRecommended", :name => "EncounterRecommended", :description => "Encounter, Recommended", :type => "encounters", :definition => "encounter", :status => "recommended" },

      { :id => "http://rdf.healthit.gov/qdm/element#FunctionalStatusOrder", :name => "FunctionalStatusOrder", :description => "Functional Status, Order", :type => "", :definition => "functional_status", :status => "ordered" },
      { :id => "http://rdf.healthit.gov/qdm/element#FunctionalStatusPerformed", :name => "FunctionalStatusPerformed", :description => "Functional Status, Performed", :type => "", :definition => "functional_status", :status => "performed" },
      { :id => "http://rdf.healthit.gov/qdm/element#FunctionalStatusRecommended", :name => "FunctionalStatusRecommended", :description => "Functional Status, Recommended", :type => "", :definition => "functional_status", :status => "recommended" },

      { :id => "http://rdf.healthit.gov/qdm/element#InterventionAdverseEvent", :name => "InterventionAdverseEvent", :description => "Intervention, Adverse Event", :type => "", :definition => "intervention_adverse_event", :status => "", :code => { "HL7 Act Code" => [ "ASSERTION" ] } },
      { :id => "http://rdf.healthit.gov/qdm/element#InterventionIntolerance", :name => "InterventionIntolerance", :description => "Intervention, Intolerance", :type => "", :definition => "intervention_intolerance", :status => "", :code => { "HL7 Act Code" => [ "ASSERTION" ] } },
      { :id => "http://rdf.healthit.gov/qdm/element#InterventionOrder", :name => "InterventionOrder", :description => "Intervention, Order", :type => "", :definition => "intervention", :status => "ordered" },
      { :id => "http://rdf.healthit.gov/qdm/element#InterventionPerformed", :name => "InterventionPerformed", :description => "Intervention, Performed", :type => "", :definition => "intervention", :status => "performed" },
      { :id => "http://rdf.healthit.gov/qdm/element#InterventionRecommended", :name => "InterventionRecommended", :description => "Intervention, Recommended", :type => "", :definition => "intervention", :status => "recommended" },

      { :id => "http://rdf.healthit.gov/qdm/element#LaboratoryTestAdverseEvent", :name => "LaboratoryTestAdverseEvent", :description => "Laboratory Test, Adverse Event", :type => "", :definition => "laboratory_test_adverse_event", :status => "", :code => { "HL7 Act Code" => [ "ASSERTION" ] } },
      { :id => "http://rdf.healthit.gov/qdm/element#LaboratoryTestIntolerance", :name => "LaboratoryTestIntolerance", :description => "Laboratory Test, Intolerance", :type => "", :definition => "laboratory_test_intolerance", :status => "", :code => { "HL7 Act Code" => [ "ASSERTION" ] } },
      { :id => "http://rdf.healthit.gov/qdm/element#LaboratoryTestOrder", :name => "LaboratoryTestOrder", :description => "Laboratory Test, Order", :type => "", :definition => "laboratory_test", :status => "ordered" },
      { :id => "http://rdf.healthit.gov/qdm/element#LaboratoryTestPerformed", :name => "LaboratoryTestPerformed", :description => "Laboratory Test, Performed", :type => "", :definition => "laboratory_test", :status => "performed" },
      { :id => "http://rdf.healthit.gov/qdm/element#LaboratoryTestRecommended", :name => "LaboratoryTestRecommended", :description => "Laboratory Test, Recommended", :type => "", :definition => "laboratory_test", :status => "recommended" },

      { :id => "http://rdf.healthit.gov/qdm/element#MedicationActive", :name => "MedicationActive", :description => "Medication, Active", :type => "", :definition => "medication", :status => "active" },
      { :id => "http://rdf.healthit.gov/qdm/element#MedicationAdministered", :name => "MedicationAdministered", :description => "Medication, Administered", :type => "", :definition => "medication", :status => "administered", :code => { "SNOMED-CT" => [ "416118004" ] } },
      { :id => "http://rdf.healthit.gov/qdm/element#MedicationAdverseEffects", :name => "MedicationAdverseEffects", :description => "Medication, Adverse Effects", :type => "", :definition => "medication_adverse_effects", :status => "", :code => { "HL7 Act Code" => [ "ASSERTION" ] } },
      { :id => "http://rdf.healthit.gov/qdm/element#MedicationAllergy", :name => "MedicationAllergy", :description => "Medication, Allergy", :type => "", :definition => "medication_allergy", :status => "", :code => { "HL7 Act Code" => [ "ASSERTION" ] } },
      { :id => "http://rdf.healthit.gov/qdm/element#MedicationDischarge", :name => "MedicationDischarge", :description => "Medication, Discharge", :type => "", :definition => "medication", :status => "discharge", :code => { "LOINC" => [ "10183-2" ] } },
      { :id => "http://rdf.healthit.gov/qdm/element#MedicationDispensed", :name => "MedicationDispensed", :description => "Medication, Dispensed", :type => "", :definition => "medication", :status => "dispensed" },
      { :id => "http://rdf.healthit.gov/qdm/element#MedicationIntolerance", :name => "MedicationIntolerance", :description => "Medication, Intolerance", :type => "", :definition => "medication_intolerance", :status => "", :code => { "HL7 Act Code" => [ "ASSERTION" ] } },
      { :id => "http://rdf.healthit.gov/qdm/element#MedicationOrder", :name => "MedicationOrder", :description => "Medication, Order", :type => "", :definition => "medication", :status => "ordered" },

      { :id => "http://rdf.healthit.gov/qdm/element#PatientCareExperience", :name => "PatientCareExperience", :description => "Patient Care Experience", :type => "", :definition => "patient_care_experience", :status => "", :code => { "SNOMED-CT" => [ "406193000" ] } },

      { :id => "http://rdf.healthit.gov/qdm/element#PatientCharacteristic", :name => "PatientCharacteristic", :description => "Patient Characteristic", :type => "", :definition => "patient_characteristic", :status => "" },
      { :id => "http://rdf.healthit.gov/qdm/element#PatientCharacteristicBirthdate", :name => "PatientCharacteristicBirthdate", :description => "Patient Characteristic, Birthdate", :type => "", :definition => "patient_characteristic_birthdate", :status => "", :code => { "LOINC" => [ "21112-8" ] } },
      { :id => "http://rdf.healthit.gov/qdm/element#PatientCharacteristicClinicalTrialParticipant", :name => "PatientCharacteristicClinicalTrialParticipant", :description => "Patient Characteristic, Clinical Trial Participant", :type => "", :definition => "patient_characteristic_clinical_trial_participant", :status => "", :code => { "HL7 Act Code" => [ "ASSERTION" ] } },
      { :id => "http://rdf.healthit.gov/qdm/element#PatientCharacteristicEthnicity", :name => "PatientCharacteristicEthnicity", :description => "Patient Characteristic, Ethnicity", :type => "", :definition => "patient_characteristic_ethnicity", :status => "", :code => { "LOINC" => [ "54133-4" ] } },
      { :id => "http://rdf.healthit.gov/qdm/element#PatientCharacteristicExpired", :name => "PatientCharacteristicExpired", :description => "Patient Characteristic, Expired", :type => "", :definition => "patient_characteristic_expired", :status => "", :code => { "HL7 Act Code" => [ "ASSERTION" ] } },
      { :id => "http://rdf.healthit.gov/qdm/element#PatientCharacteristicPayer", :name => "PatientCharacteristicPayer", :description => "Patient Characteristic, Payer", :type => "", :definition => "patient_characteristic_payer", :status => "", :code => { "LOINC" => [ "48768-6" ] } },
      { :id => "http://rdf.healthit.gov/qdm/element#PatientCharacteristicRace", :name => "PatientCharacteristicRace", :description => "Patient Characteristic, Race", :type => "", :definition => "patient_characteristic_race", :status => "", :code => { "LOINC" => [ "32624-9" ] } },
      { :id => "http://rdf.healthit.gov/qdm/element#PatientCharacteristicSex", :name => "PatientCharacteristicSex", :description => "Patient Characteristic, Sex", :type => "", :definition => "patient_characteristic_gender", :status => "", :code => { "SNOMED-CT" => [ "263495000" ] } },

      { :id => "http://rdf.healthit.gov/qdm/element#PhysicalExamOrder", :name => "PhysicalExamOrder", :description => "Physical Exam, Order", :type => "", :definition => "physical_exam", :status => "ordered", :code => { "SNOMED-CT" => [ "5880005" ] } },
      { :id => "http://rdf.healthit.gov/qdm/element#PhysicalExamPerformed", :name => "PhysicalExamPerformed", :description => "Physical Exam, Performed", :type => "", :definition => "physical_exam", :status => "performed", :code => { "SNOMED-CT" => [ "5880005" ] } },
      { :id => "http://rdf.healthit.gov/qdm/element#PhysicalExamRecommended", :name => "PhysicalExamRecommended", :description => "Physical Exam, Recommended", :type => "", :definition => "physical_exam", :status => "recommended", :code => { "SNOMED-CT" => [ "5880005" ] } },

      { :id => "http://rdf.healthit.gov/qdm/element#ProcedureAdverseEvent", :name => "ProcedureAdverseEvent", :description => "Procedure, Adverse Event", :type => "", :definition => "procedure_adverse_event", :status => "", :code => { "HL7 Act Code" => [ "ASSERTION" ] } },
      { :id => "http://rdf.healthit.gov/qdm/element#ProcedureIntolerance", :name => "ProcedureIntolerance", :description => "Procedure, Intolerance", :type => "", :definition => "procedure_intolerance", :status => "", :code => { "HL7 Act Code" => [ "ASSERTION" ] } },
      { :id => "http://rdf.healthit.gov/qdm/element#ProcedureOrder", :name => "ProcedureOrder", :description => "Procedure, Order", :type => "", :definition => "procedure", :status => "ordered" },
      { :id => "http://rdf.healthit.gov/qdm/element#ProcedurePerformed", :name => "ProcedurePerformed", :description => "Procedure, Performed", :type => "", :definition => "procedure", :status => "performed" },
      { :id => "http://rdf.healthit.gov/qdm/element#ProcedureRecommended", :name => "ProcedureRecommended", :description => "Procedure, Recommended", :type => "", :definition => "procedure", :status => "recommended" },

      { :id => "http://rdf.healthit.gov/qdm/element#ProviderCareExperience", :name => "ProviderCareExperience", :description => "Provider Care Experience", :type => "", :definition => "provider_care_experience", :status => "", :code => { "SNOMED-CT" => [ "405193005" ] } },

      { :id => "http://rdf.healthit.gov/qdm/element#ProviderCharacteristic", :name => "ProviderCharacteristic", :description => "Provider Characteristic", :type => "", :definition => "provider_characteristic", :status => "" },

      { :id => "http://rdf.healthit.gov/qdm/element#RiskCategoryAssessment", :name => "RiskCategoryAssessment", :description => "Risk Category/Assessment", :type => "", :definition => "risk_category_assessment", :status => "" },

      { :id => "http://rdf.healthit.gov/qdm/element#SubstanceAdministered", :name => "SubstanceAdministered", :description => "Substance, Administered", :type => "", :definition => "substance", :status => "administered", :code => { "SNOMED-CT" => [ "416118004" ] } },
      { :id => "http://rdf.healthit.gov/qdm/element#SubstanceAdverseEvent", :name => "SubstanceAdverseEvent", :description => "Substance, Adverse Event", :type => "", :definition => "substance_adverse_event", :status => "", :code => { "HL7 Act Code" => [ "ASSERTION" ] } },
      { :id => "http://rdf.healthit.gov/qdm/element#SubstanceAllergy", :name => "SubstanceAllergy", :description => "Substance, Allergy", :type => "", :definition => "substance_allergy", :status => "", :code => { "HL7 Act Code" => [ "ASSERTION" ] } },
      { :id => "http://rdf.healthit.gov/qdm/element#SubstanceIntolerance", :name => "SubstanceIntolerance", :description => "Substance, Intolerance", :type => "", :definition => "substance_intolerance", :status => "", :code => { "HL7 Act Code" => [ "ASSERTION" ] } },
      { :id => "http://rdf.healthit.gov/qdm/element#SubstanceOder", :name => "SubstanceOrder", :description => "Substance, Order", :type => "", :definition => "substance", :status => "ordered" },
      { :id => "http://rdf.healthit.gov/qdm/element#SubstanceRecommended", :name => "SubstanceRecommended", :description => "Substance, Recommended", :type => "", :definition => "substance", :status => "recommended" },

      { :id => "http://rdf.healthit.gov/qdm/element#SymptomActive", :name => "SymptomActive", :description => "Symptom, Active", :type => "", :definition => "symptom", :status => "active", :code => { "SNOMED-CT" => [ "418799008" ] } },
      { :id => "http://rdf.healthit.gov/qdm/element#SymptomAssessed", :name => "SymptomAssessed", :description => "Symptom, Assessed", :type => "", :definition => "symptom", :status => "assessed", :code => { "SNOMED-CT" => [ "418799008" ] } },
      { :id => "http://rdf.healthit.gov/qdm/element#SymptomInactive", :name => "SymptomInactive", :description => "Symptom, Inactive", :type => "", :definition => "symptom", :status => "inactive", :code => { "SNOMED-CT" => [ "418799008" ] } },
      { :id => "http://rdf.healthit.gov/qdm/element#SymptomResolved", :name => "SymptomResolved", :description => "Symptom, Resolved", :type => "", :definition => "symptom", :status => "resolved", :code => { "SNOMED-CT" => [ "418799008" ] } },

      { :id => "http://rdf.healthit.gov/qdm/element#TransferFrom", :name => "TransferFrom", :description => "Transfer From", :type => "", :definition => "transfer_from", :status => "" },
      { :id => "http://rdf.healthit.gov/qdm/element#TransferTo", :name => "TransferTo", :description => "Transfer To", :type => "", :definition => "transfer_to", :status => "" },
    ]

    QDM_HQMF_LOGICAL_CONJUNCTION_MAPPING = {
      "http://rdf.healthit.gov/qdm/element#And" => "allTrue",
      "http://rdf.healthit.gov/qdm/element#Or" => "atLeastOneTrue",
      "http://rdf.healthit.gov/qdm/element#Not" => "allFalse"
    }

    QDM_HQMF_TEMPORAL_TYPE_MAPPING = {
      "http://rdf.healthit.gov/qdm/element#EndsAfterEndOf" => "EAE",
      "http://rdf.healthit.gov/qdm/element#StartsAfterOrConcurrentWithEndOf" => "SAEORSCWE",
      "http://rdf.healthit.gov/qdm/element#EndsDuring" => "EDU",
      "http://rdf.healthit.gov/qdm/element#StartsBeforeOrConcurrentWithEndOf" => "SBEORSCWE",
      "http://rdf.healthit.gov/qdm/element#EndsConcurrentWithStartOf" => "ECWS",
      "http://rdf.healthit.gov/qdm/element#StartsDuring" => "SDU",
      "http://rdf.healthit.gov/qdm/element#StartsAfterOrConcurrentWithStartOf" => "SASORSCW",
      "http://rdf.healthit.gov/qdm/element#StartsAfterStartOf" => "SAS",
      "http://rdf.healthit.gov/qdm/element#EndsBeforeEndOf" => "EBE",
      "http://rdf.healthit.gov/qdm/element#EndsBeforeOrConcurrentWithEndOf" => "EBEORECW",
      "http://rdf.healthit.gov/qdm/element#EndsBeforeStartOf" => "EBS",
      "http://rdf.healthit.gov/qdm/element#During" => "DURING",
      "http://rdf.healthit.gov/qdm/element#EndsAfterOrConcurrentWithStartOf" => "EASORECWS",
      "http://rdf.healthit.gov/qdm/element#StartsAfterEndOf" => "SAE",
      "http://rdf.healthit.gov/qdm/element#StartsBeforeEndOf" => "SBE",
      "http://rdf.healthit.gov/qdm/element#StartsBeforeStartOf" => "SBS",
      "http://rdf.healthit.gov/qdm/element#StartsBeforeOrConcurrentWithStartOf" => "SBSORSCW",
      "http://rdf.healthit.gov/qdm/element#EndsAfterOrConcurrentWithEndOf" => "EAEORECW",
      "http://rdf.healthit.gov/qdm/element#StartsConcurrentWithEndOf" => "SCWE",
      "http://rdf.healthit.gov/qdm/element#EndsAfterStartOf" => "EAS",
      "http://rdf.healthit.gov/qdm/element#EndsBeforeOrConcurrentWithStartOf" => "EBSORECWS",
      "http://rdf.healthit.gov/qdm/element#EndsConcurrentWith" => "ECW",
      "http://rdf.healthit.gov/qdm/element#StartsConcurrentWith" => "SCW",
      "http://rdf.healthit.gov/qdm/element#ConcurrentWith" => "CONCURRENT",
      "http://rdf.healthit.gov/qdm/element#Overlaps" => "OVERLAP"
    }
  end
end