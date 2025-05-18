// model.dart
class PersonalInformation {
  String? fullName;
  DateTime? birthDate;
  String? gender;
  String? maritalStatus;
  int? dependents;
  bool? hasVehicle;
  Vehicle? vehicle;
  Professional? professional;
  Financial? financial;

  PersonalInformation({
    this.fullName,
    this.birthDate,
    this.gender,
    this.maritalStatus,
    this.dependents,
    this.hasVehicle,
    this.vehicle,
    this.professional,
    this.financial,
  });

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'birthDate': birthDate?.toIso8601String(),
    'gender': gender,
    'maritalStatus': maritalStatus,
    'dependents': dependents,
    'hasVehicle': hasVehicle,
    'vehicle': vehicle?.toJson(),
    'professional': professional?.toJson(),
    'financial': financial?.toJson(),
  };
}

class Vehicle {
  String? brand;
  String? model;
  int? acquisitionYear;
  double? estimatedValue;
  bool? isFinanced;

  Vehicle({
    this.brand,
    this.model,
    this.acquisitionYear,
    this.estimatedValue,
    this.isFinanced,
  });

  Map<String, dynamic> toJson() => {
    'brand': brand,
    'model': model,
    'acquisitionYear': acquisitionYear,
    'estimatedValue': estimatedValue,
    'isFinanced': isFinanced,
  };
}

class Professional {
  String? profession;
  String? sector;
  String? employer;
  String? contractType;
  int? yearsOfService;

  Professional({
    this.profession,
    this.sector,
    this.employer,
    this.contractType,
    this.yearsOfService,
  });

  Map<String, dynamic> toJson() => {
    'profession': profession,
    'sector': sector,
    'employer': employer,
    'contractType': contractType,
    'yearsOfService': yearsOfService,
  };
}

class Financial {
  double? monthlyNetSalary;
  double? additionalIncome;
  double? fixedCharges;

  Financial({
    this.monthlyNetSalary,
    this.additionalIncome,
    this.fixedCharges,
  });

  Map<String, dynamic> toJson() => {
    'monthlyNetSalary': monthlyNetSalary,
    'additionalIncome': additionalIncome,
    'fixedCharges': fixedCharges,
  };
}
