/// Doctor model
class Doctor {
  final String doctorId;
  final String email;
  final String fullName;
  final String? specialty;

  Doctor({
    required this.doctorId,
    required this.email,
    required this.fullName,
    this.specialty,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      doctorId: json['doctor_id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      specialty: json['specialty'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'doctor_id': doctorId,
      'email': email,
      'full_name': fullName,
      if (specialty != null) 'specialty': specialty,
    };
  }
}
