import "dart:convert";

import "package:aw40_hub_frontend/dtos/diagnosis_dto.dart";
import "package:aw40_hub_frontend/models/case_model.dart";
import "package:aw40_hub_frontend/models/diagnosis_model.dart";
import "package:aw40_hub_frontend/services/services.dart";
import "package:collection/collection.dart";
import "package:flutter/material.dart";
import "package:http/http.dart";
import "package:logging/logging.dart";

class DiagnosisProvider with ChangeNotifier {
  DiagnosisProvider(this._httpService);
  final HttpService _httpService;

  final Logger _logger = Logger("diagnosis_provider");
  late String workShopId;

  Future<List<DiagnosisModel>> getDiagnoses(
    Future<List<CaseModel>> Function(BuildContext) getCaseModels,
    BuildContext context,
  ) async {
    final List<CaseModel> cases = await getCaseModels(context);
    final List<String> caseIDs = cases.map((e) => e.id).toList();

    final List<Future<DiagnosisModel?>> individualDiagnosisRequests =
        caseIDs.map(getDiagnosis).toList();

    final List<DiagnosisModel?> diagnoses =
        await Future.wait(individualDiagnosisRequests);
    return diagnoses.whereNotNull().toList();
  }

  Future<DiagnosisModel?> getDiagnosis(String caseId) async {
    final Response response =
        await _httpService.getDiagnosis(workShopId, caseId);
    if (response.statusCode != 200) {
      _logger.warning(
        "Could not get diagnosis. "
        "${response.statusCode}: ${response.reasonPhrase}",
      );
      return null;
    }

    final decodedJson = jsonDecode(response.body);
    if (decodedJson is! Map<String, dynamic>) return null;
    final Map<String, dynamic> body = decodedJson;
    final DiagnosisDto diagnosisDto = DiagnosisDto.fromJson(body);
    return diagnosisDto.toModel();
  }

  Future<DiagnosisModel?> startDiagnosis(String caseId) async {
    final Response response =
        await _httpService.startDiagnosis(workShopId, caseId);
    if (response.statusCode != 201) {
      _logger.warning(
        "Could not start diagnosis. "
        "${response.statusCode}: ${response.reasonPhrase}",
      );
      return null;
    }

    final decodedJson = jsonDecode(response.body);
    if (decodedJson is! Map<String, dynamic>) return null;
    final Map<String, dynamic> body = decodedJson;
    final DiagnosisDto receivedDiagnosis = DiagnosisDto.fromJson(body);
    final DiagnosisModel diagnosisModel = receivedDiagnosis.toModel();
    return diagnosisModel;
  }

  Future<bool> deleteDiagnosis(String caseId) async {
    final Response response =
        await _httpService.deleteDiagnosis(workShopId, caseId);
    if (response.statusCode != 200) {
      _logger.warning(
        "Could not delete diagnosis. "
        "${response.statusCode}: ${response.reasonPhrase}",
      );
      return false;
    }

    notifyListeners();
    return true;
  }
}
