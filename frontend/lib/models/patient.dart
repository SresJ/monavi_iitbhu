/// Patient contact information
class PatientContact {
  final String? email;
  final String? phone;

  PatientContact({
    this.email,
    this.phone,
  });

  factory PatientContact.fromJson(Map<String, dynamic> json) {
    return PatientContact(
      email: json['email'] as String?,
      phone: json['phone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
    };
  }
}

/// Helper to capitalize first letter of each word
String _capitalizeWords(String text) {
  if (text.isEmpty) return text;
  return text.split(' ').map((word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join(' ');
}

/// Helper to capitalize first letter only
String _capitalizeFirst(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1).toLowerCase();
}

/// Patient model
class Patient {
  final String patientId;
  final String fullName;
  final int? age;
  final String? sex;
  final String? mrn;
  final PatientContact? contact;
  final DateTime createdAt;
  final DateTime updatedAt;

  Patient({
    required this.patientId,
    required this.fullName,
    this.age,
    this.sex,
    this.mrn,
    this.contact,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      patientId: json['patient_id'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      age: json['age'] as int?,
      sex: json['sex'] as String?,
      mrn: json['mrn'] as String?,
      contact: json['contact'] != null
          ? PatientContact.fromJson(json['contact'] as Map<String, dynamic>)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patient_id': patientId,
      'full_name': fullName,
      if (age != null) 'age': age,
      if (sex != null) 'sex': sex,
      if (mrn != null) 'mrn': mrn,
      if (contact != null) 'contact': contact!.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Get patient initials for avatar
  String get initials {
    final parts = fullName.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
  }

  /// Get capitalized full name
  String get displayName => _capitalizeWords(fullName);

  /// Get capitalized sex/gender
  String get displaySex => sex != null ? _capitalizeFirst(sex!) : '';

  /// Get display age/sex with proper capitalization
  String get ageSexDisplay {
    final List<String> parts = [];
    if (age != null) parts.add('$age yrs');
    if (sex != null) parts.add(_capitalizeFirst(sex!));
    return parts.join(' · ');
  }

  /// Get avatar image path (random between profile and profile2 based on patient ID)
  String get avatarPath {
    // Use hash of patientId for consistent random selection
    final hash = patientId.hashCode;
    return hash.isEven ? 'assets/profile1.jpg' : 'assets/profile2.jpg';
  }
}
