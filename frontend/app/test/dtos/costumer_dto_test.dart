import "package:aw40_hub_frontend/dtos/customer_dto.dart";
import "package:aw40_hub_frontend/models/customer_model.dart";
import "package:aw40_hub_frontend/utils/enums.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  group("CustomerDto primary constructor", () {
    const id = AnonymousCustomerId.anonymous;
    const firstname = "some_firstname";
    const lastname = "some_lastname";
    const email = "some_email";
    const phone = "some_phone";
    const street = "some_street";
    const housenumber = "some_housenumber";
    const postcode = "some_postcode";
    const city = "some_city";
    final CustomerDto customerDto = CustomerDto(
      id,
      firstname,
      lastname,
      email,
      phone,
      street,
      housenumber,
      postcode,
      city,
    );
    test("correctly assigns id", () {
      expect(customerDto.id, id);
    });
    test("correctly assigns firstname", () {
      expect(customerDto.firstname, firstname);
    });
    test("correctly assigns lastname", () {
      expect(customerDto.lastname, lastname);
    });
    test("correctly assigns email", () {
      expect(customerDto.email, email);
    });
    test("correctly assigns phone", () {
      expect(customerDto.phone, phone);
    });
    test("correctly assigns street", () {
      expect(customerDto.street, street);
    });
    test("correctly assigns housenumber", () {
      expect(customerDto.housenumber, housenumber);
    });
    test("correctly assigns postcode", () {
      expect(customerDto.postcode, postcode);
    });
    test("correctly assigns city", () {
      expect(customerDto.city, city);
    });
  });
  // TODO extend tests
  group("CustomerDto fromJson constructor", () {
    const id = AnonymousCustomerId.anonymous;
    final Map<String, dynamic> json = <String, dynamic>{
      "_id": id.name,
    };
    final CustomerDto customerDto = CustomerDto.fromJson(json);
    test("correctly assigns id", () {
      expect(customerDto.id, id);
    });
  });
  group("VehicleDto toJson method", () {
    const id = AnonymousCustomerId.anonymous;
    final CustomerDto customerDto = CustomerDto(
      id,
    );
    final Map<String, dynamic> json = customerDto.toJson();
    test("correctly assigns id", () {
      expect(json["_id"], id.name);
    });
  });

  group("CustomerDto toModel method", () {
    const id = AnonymousCustomerId.anonymous;
    final CustomerDto customerDto = CustomerDto(
      id,
    );
    final CustomerModel customerModel = customerDto.toModel();
    test("correctly assigns id", () {
      expect(customerModel.id, id);
    });
  });
}
