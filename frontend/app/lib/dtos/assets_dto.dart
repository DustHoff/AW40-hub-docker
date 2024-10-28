import "package:aw40_hub_frontend/models/assets_model.dart";
import "package:json_annotation/json_annotation.dart";

part "assets_dto.g.dart";

@JsonSerializable()
class AssetsDto {
  AssetsDto(
    this.id,
  );

  factory AssetsDto.fromJson(Map<String, dynamic> json) {
    return _$AssetsDtoFromJson(json);
  }
  Map<String, dynamic> toJson() => _$AssetsDtoToJson(this);

  AssetsModel toModel() {
    return AssetsModel(
      id: id,
    );
  }

  @JsonKey(name: "_id")
  String id;
}
