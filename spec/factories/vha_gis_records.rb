# frozen_string_literal: false

FactoryBot.define do
  factory :vha_gis_record, class: Hash do
    gis_attrs do
      {
        'OBJECTID' => 224,
        'FacilityDataDate' => '10-31-2016',
        'OutpatientServicesDataDate' => 1_477_872_000_000,
        'StationID' => 538,
        'VisnID' => 20,
        'StationNumber' => '648',
        'StationName' => 'Portland VA Medical Center',
        'CommonStationName' => 'Portland',
        'CocClassification' => 'VA Medical Center (VAMC)',
        'CocClassificationAttribute' => 'Firm',
        'Building' => '',
        'Street' => '3710 Southwest US Veterans Hospital Road',
        'Suite' => nil,
        'City' => 'Portland',
        'State' => 'OR',
        'Zip' => '97239',
        'Zip4' => '2964',
        'MainPhone' => '503-721-1498 x',
        'MainFax' => '503-273-5319 x',
        'AfterHoursPhone' => '503-220-8262 x',
        'PatientAdvocatePhone' => '503-273-5308 x',
        'EnrollmentCoordinatorPhone' => '503-273-5069 x',
        'PharmacyPhone' => '503-273-5183 x',
        'Monday' => '24/7',
        'Tuesday' => '24/7',
        'Wednesday' => '24/7',
        'Thursday' => '24/7',
        'Friday' => '24/7',
        'Saturday' => '24/7',
        'Sunday' => '24/7',
        'Latitude' => 45.49746145,
        'Longitude' => -122.68287208,
        'Audiology' => '',
        'ComplementaryAlternativeMed' => '',
        'DentalServices' => '',
        'DiagnosticServices' => '',
        'ImagingAndRadiology' => '',
        'LabServices' => '',
        'EmergencyDept' => '',
        'EyeCare' => '',
        'MentalHealthCare' => 'YES',
        'OutpatientMHCare' => '',
        'OutpatientSpecMHCare' => '',
        'VocationalAssistance' => '',
        'OutpatientMedicalSpecialty' => '',
        'AllergyAndImmunology' => '',
        'CardiologyCareServices' => '',
        'DermatologyCareServices' => '',
        'Diabetes' => '',
        'Dialysis' => '',
        'Endocrinology' => '',
        'Gastroenterology' => '',
        'Hematology' => '',
        'InfectiousDisease' => '',
        'InternalMedicine' => '',
        'Nephrology' => '',
        'Neurology' => '',
        'Oncology' => '',
        'PulmonaryRespiratoryDisease' => '',
        'Rheumatology' => '',
        'SleepMedicine' => '',
        'OutpatientSurgicalSpecialty' => '',
        'CardiacSurgery' => '',
        'ColoRectalSurgery' => '',
        'ENT' => '',
        'GeneralSurgery' => '',
        'Gynecology' => '',
        'Neurosurgery' => '',
        'Orthopedics' => '',
        'PainManagement' => '',
        'PlasticSurgery' => '',
        'Podiatry' => '',
        'ThoracicSurgery' => '',
        'Urology' => '',
        'VascularSurgery' => '',
        'PrimaryCare' => 'YES',
        'Rehabilitation' => '',
        'UrgentCare' => '',
        'WellnessAndPreventativeCare' => '',
        'Website_URL' => 'http://www.portland.va.gov/',
        'MHClinicPhone' => '5032735187',
        'Extension' => nil,
        'Primary_Care_Urgent_Score' => 0.66,
        'Specialty_Care_Urgent_Score' => 0.67,
        'Primary_Care_Routine_Score' => 0.81,
        'Specialty_Care_Routine_Score' => 0.77,
        'ScoreDateRange' => 'Jun 2016 - Nov 2016'
      }
    end
    geometry do
      {
        'x' => -13_656_996.4607131,
        'y' => 5_700_180.43265912
      }
    end
    initialize_with { { 'attributes' => gis_attrs, 'geometry' => geometry } }
  end

  factory :vha_gis_record_v3, class: Hash do
    gis_attrs do
      {
        'OBJECTID' => 224,
        'FacilityDataDate' => '10-31-2016',
        'OutpatientServicesDataDate' => 1_477_872_000_000,
        'StationID' => 538,
        'VisnID' => 20,
        'StationNumber' => '648',
        'StationName' => 'Portland VA Medical Center',
        'CommonStationName' => 'Portland',
        'CocClassification' => 'VA Medical Center (VAMC)',
        'CocClassificationAttribute' => 'Firm',
        'Building' => '',
        'Street' => '3710 Southwest US Veterans Hospital Road',
        'Suite' => nil,
        'City' => 'Portland',
        'State' => 'OR',
        'Zip' => '97239',
        'Zip4' => '2964',
        'MainPhone' => '503-721-1498 x',
        'MainFax' => '503-273-5319 x',
        'AfterHoursPhone' => '503-220-8262 x',
        'PatientAdvocatePhone' => '503-273-5308 x',
        'EnrollmentCoordinatorPhone' => '503-273-5069 x',
        'PharmacyPhone' => '503-273-5183 x',
        'Monday' => '24/7',
        'Tuesday' => '24/7',
        'Wednesday' => '24/7',
        'Thursday' => '24/7',
        'Friday' => '24/7',
        'Saturday' => '24/7',
        'Sunday' => '24/7',
        'Latitude' => 45.49746145,
        'Longitude' => -122.68287208,
        'Audiology' => '',
        'ComplementaryAlternativeMed' => '',
        'DentalServices' => '',
        'DiagnosticServices' => '',
        'ImagingAndRadiology' => '',
        'LabServices' => '',
        'EmergencyDept' => '',
        'EyeCare' => '',
        'MentalHealthCare' => 'YES',
        'OutpatientMHCare' => '',
        'OutpatientSpecMHCare' => '',
        'VocationalAssistance' => '',
        'OutpatientMedicalSpecialty' => '',
        'AllergyAndImmunology' => '',
        'CardiologyCareServices' => '',
        'DermatologyCareServices' => '',
        'Diabetes' => '',
        'Dialysis' => '',
        'Endocrinology' => '',
        'Gastroenterology' => '',
        'Hematology' => '',
        'InfectiousDisease' => '',
        'InternalMedicine' => '',
        'Nephrology' => '',
        'Neurology' => '',
        'Oncology' => '',
        'PulmonaryRespiratoryDisease' => '',
        'Rheumatology' => '',
        'SleepMedicine' => '',
        'OutpatientSurgicalSpecialty' => '',
        'CardiacSurgery' => '',
        'ColoRectalSurgery' => '',
        'ENT' => '',
        'GeneralSurgery' => '',
        'Gynecology' => '',
        'Neurosurgery' => '',
        'Orthopedics' => '',
        'PainManagement' => '',
        'PlasticSurgery' => '',
        'Podiatry' => '',
        'ThoracicSurgery' => '',
        'Urology' => '',
        'VascularSurgery' => '',
        'PrimaryCare' => 'YES',
        'Rehabilitation' => '',
        'UrgentCare' => '',
        'WellnessAndPreventativeCare' => '',
        'Website_URL' => 'http://www.portland.va.gov/',
        'MHPhone' => '5032735187',
        'Extension' => nil,
        'SHEP_Primary_Care_Urgent' => 0.66,
        'SHEP_Specialty_Care_Urgent' => 0.67,
        'SHEP_Primary_Care_Routine' => 0.81,
        'SHEP_Specialty_Care_Routine' => 0.77,
        'SHEP_ScoreDateRange' => 'Jun 2016 - Nov 2016',
        'ACCESS_Stat_Consult_Score' => 0.781818,
        'ACCESS_Stat_Consult_Sample' => 55,
        'ACCESS_Specialty_Care_Score' => 6.977099,
        'ACCESS_Specialty_Care_Sample' => 393,
        'ACCESS_Primary_Care_Score' => 5.4,
        'ACCESS_Primary_Care_Sample' => 20,
        'ACCESS_Mental_Health_Score' => 8.266666,
        'ACCESS_Mental_Health_Sample' => 15
      }
    end
    geometry do
      {
        'x' => -13_656_996.4607131,
        'y' => 5_700_180.43265912
      }
    end
    initialize_with { { 'attributes' => gis_attrs, 'geometry' => geometry } }
  end
end
