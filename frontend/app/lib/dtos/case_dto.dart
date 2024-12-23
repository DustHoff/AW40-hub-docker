import "package:aw40_hub_frontend/dtos/obd_data_dto.dart";
import "package:aw40_hub_frontend/dtos/symptom_dto.dart";
import "package:aw40_hub_frontend/dtos/timeseries_data_dto.dart";
import "package:aw40_hub_frontend/models/case_model.dart";
import "package:aw40_hub_frontend/utils/enums.dart";
import "package:json_annotation/json_annotation.dart";

part "case_dto.g.dart";

@JsonSerializable()
class CaseDto {
  CaseDto(
    this.id,
    this.timestamp,
    this.occasion,
    this.milage,
    this.status,
    this.customerId,
    this.vehicleVin,
    this.workshopId,
    this.diagnosisId,
    this.timeseriesData,
    this.obdData,
    this.symptoms,
    this.timeseriesDataAdded,
    this.obdDataAdded,
    this.symptomsAdded,
  );

  factory CaseDto.fromJson(Map<String, dynamic> json) {
    return _$CaseDtoFromJson(json);
  }
  Map<String, dynamic> toJson() => _$CaseDtoToJson(this);

  CaseModel toModel() {
    return CaseModel(
      id: id,
      timestamp: timestamp,
      occasion: occasion,
      milage: milage,
      status: status,
      customerId: customerId,
      vehicleVin: vehicleVin,
      workshopId: workshopId,
      diagnosisId: diagnosisId,
      timeseriesData: timeseriesData.map((e) => e.toModel()).toList(),
      obdData: obdData.map((e) => e.toModel()).toList(),
      symptoms: symptoms.map((e) => e.toModel()).toList(),
      timeseriesDataAdded: timeseriesDataAdded,
      obdDataAdded: obdDataAdded,
      symptomsAdded: symptomsAdded,
    );
  }

  @JsonKey(name: "_id")
  String id;
  DateTime timestamp;
  CaseOccasion occasion;
  int milage;
  CaseStatus status;
  @JsonKey(name: "customer_id")
  String customerId;
  @JsonKey(name: "vehicle_vin")
  String vehicleVin;
  @JsonKey(name: "workshop_id")
  String workshopId;
  @JsonKey(name: "diagnosis_id")
  String? diagnosisId;
  @JsonKey(name: "timeseries_data")
  List<TimeseriesDataDto> timeseriesData;
  @JsonKey(name: "obd_data")
  List<ObdDataDto> obdData;
  List<SymptomDto> symptoms;
  @JsonKey(name: "timeseries_data_added")
  int timeseriesDataAdded;
  @JsonKey(name: "obd_data_added")
  int obdDataAdded;
  @JsonKey(name: "symptoms_added")
  int symptomsAdded;
}
