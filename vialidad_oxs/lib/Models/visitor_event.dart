/// Model representing a visitor event/registration in the system
/// This model handles visitor check-ins, check-outs, and related information
class VisitorEvent {
  final DateTime creationDate;
  final String visitorName;
  final String identificationType;
  final String schoolDestination;
  final String reasonForVisit;
  final DateTime arriveDate;
  final DateTime? leaveDate;
  final String observations;
  final int createdBy;
  final String device;
  final int status;
  final int identificationNumber;
  final bool communityMember;
  final int? updatedBy;
  final DateTime? updateDate;
  final String? updateDeviceName;

  const VisitorEvent({
    required this.creationDate,
    required this.visitorName,
    required this.identificationType,
    required this.schoolDestination,
    required this.reasonForVisit,
    required this.arriveDate,
    this.leaveDate,
    required this.observations,
    required this.createdBy,
    required this.device,
    required this.status,
    required this.identificationNumber,
    required this.communityMember,
    this.updatedBy,
    this.updateDate,
    this.updateDeviceName,
  });

  /// Create VisitorEvent from JSON response
  factory VisitorEvent.fromJson(Map<String, dynamic> json) {
    return VisitorEvent(
      creationDate: DateTime.parse(json['creationDate'] as String),
      visitorName: json['visitorName'] as String,
      identificationType: json['identificationType'] as String,
      schoolDestination: json['schoolDestination'] as String,
      reasonForVisit: json['reasonForVisit'] as String,
      arriveDate: DateTime.parse(json['arriveDate'] as String),
      leaveDate: json['leaveDate'] != null
          ? DateTime.parse(json['leaveDate'] as String)
          : null,
      observations: json['observations'] as String,
      createdBy: json['createdBy'] as int,
      device: json['device'] as String,
      status: json['status'] as int,
      identificationNumber: json['identification_number'] as int,
      communityMember: json['communityMember'] as bool,
      updatedBy: json['updatedBy'] as int?,
      updateDate: json['updateDate'] != null
          ? DateTime.parse(json['updateDate'] as String)
          : null,
      updateDeviceName: json['updateDeviceName'] as String?,
    );
  }

  /// Convert VisitorEvent to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'creationDate': creationDate.toIso8601String(),
      'visitorName': visitorName,
      'identificationType': identificationType,
      'schoolDestination': schoolDestination,
      'reasonForVisit': reasonForVisit,
      'arriveDate': arriveDate.toIso8601String(),
      'leaveDate': leaveDate?.toIso8601String(),
      'observations': observations,
      'createdBy': createdBy,
      'device': device,
      'status': status,
      'identification_number': identificationNumber,
      'communityMember': communityMember,
      'updatedBy': updatedBy,
      'updateDate': updateDate?.toIso8601String(),
      'updateDeviceName': updateDeviceName,
    };
  }

  /// Create a copy of this VisitorEvent with some fields updated
  VisitorEvent copyWith({
    DateTime? creationDate,
    String? visitorName,
    String? identificationType,
    String? schoolDestination,
    String? reasonForVisit,
    DateTime? arriveDate,
    DateTime? leaveDate,
    String? observations,
    int? createdBy,
    String? device,
    int? status,
    int? identificationNumber,
    bool? communityMember,
    int? updatedBy,
    DateTime? updateDate,
    String? updateDeviceName,
  }) {
    return VisitorEvent(
      creationDate: creationDate ?? this.creationDate,
      visitorName: visitorName ?? this.visitorName,
      identificationType: identificationType ?? this.identificationType,
      schoolDestination: schoolDestination ?? this.schoolDestination,
      reasonForVisit: reasonForVisit ?? this.reasonForVisit,
      arriveDate: arriveDate ?? this.arriveDate,
      leaveDate: leaveDate ?? this.leaveDate,
      observations: observations ?? this.observations,
      createdBy: createdBy ?? this.createdBy,
      device: device ?? this.device,
      status: status ?? this.status,
      identificationNumber: identificationNumber ?? this.identificationNumber,
      communityMember: communityMember ?? this.communityMember,
      updatedBy: updatedBy ?? this.updatedBy,
      updateDate: updateDate ?? this.updateDate,
      updateDeviceName: updateDeviceName ?? this.updateDeviceName,
    );
  }

  /// Check if the visitor is currently checked in (no leave date)
  bool get isCheckedIn => leaveDate == null;

  /// Check if the visitor has left (has leave date)
  bool get hasLeft => leaveDate != null;

  /// Get the duration of the visit (if visitor has left)
  Duration? get visitDuration {
    if (leaveDate == null) return null;
    return leaveDate!.difference(arriveDate);
  }

  /// Get status description based on status code
  String get statusDescription {
    switch (status) {
      case 0:
        return 'Cancelado';
      case 1:
        return 'Ingreso registrado';
      case 2:
        return 'Confirmado x destino.';
      case 3:
        return 'Agendado';
      case 4:
        return 'Salida registrada';
      default:
        return 'Desconocido';
    }
  }

  /// Get formatted arrival date and time
  String get formattedArrivalDateTime {
    return '${arriveDate.day}/${arriveDate.month}/${arriveDate.year} ${arriveDate.hour.toString().padLeft(2, '0')}:${arriveDate.minute.toString().padLeft(2, '0')}';
  }

  /// Get formatted leave date and time (if available)
  String? get formattedLeaveDateTime {
    if (leaveDate == null) return null;
    return '${leaveDate!.day}/${leaveDate!.month}/${leaveDate!.year} ${leaveDate!.hour.toString().padLeft(2, '0')}:${leaveDate!.minute.toString().padLeft(2, '0')}';
  }

  /// Check if this is a community member visit
  bool get isCommunityMemberVisit => communityMember;

  /// Check if this is an external visitor
  bool get isExternalVisitor => !communityMember;

  /// Validate if the visitor event has required information
  bool get isValid {
    return visitorName.isNotEmpty &&
        identificationType.isNotEmpty &&
        schoolDestination.isNotEmpty &&
        reasonForVisit.isNotEmpty &&
        identificationNumber > 0;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VisitorEvent &&
        other.creationDate == creationDate &&
        other.visitorName == visitorName &&
        other.identificationType == identificationType &&
        other.schoolDestination == schoolDestination &&
        other.reasonForVisit == reasonForVisit &&
        other.arriveDate == arriveDate &&
        other.leaveDate == leaveDate &&
        other.observations == observations &&
        other.createdBy == createdBy &&
        other.device == device &&
        other.status == status &&
        other.identificationNumber == identificationNumber &&
        other.communityMember == communityMember;
  }

  @override
  int get hashCode {
    return Object.hash(
      creationDate,
      visitorName,
      identificationType,
      schoolDestination,
      reasonForVisit,
      arriveDate,
      leaveDate,
      observations,
      createdBy,
      device,
      status,
      identificationNumber,
      communityMember,
    );
  }

  @override
  String toString() {
    return 'VisitorEvent(visitorName: $visitorName, identificationType: $identificationType, schoolDestination: $schoolDestination, status: $statusDescription, isCheckedIn: $isCheckedIn)';
  }
}

/// Enum for visitor event status
enum VisitorEventStatus {
  canceled(0, 'Cancelado'),
  arrived(1, 'Ingreso registrado'),
  confirmed(2, 'Confirmado x destino.'),
  scheduled(3, 'Agendado'),
  departed(4, 'Salida registrada'),
  otherwise(5, 'Otro');

  const VisitorEventStatus(this.code, this.description);

  final int code;
  final String description;

  static VisitorEventStatus fromCode(int code) {
    return VisitorEventStatus.values.firstWhere(
      (status) => status.code == code,
      orElse: () => VisitorEventStatus.otherwise,
    );
  }
}

/// Enum for common identification types
enum IdentificationType {
  cartelon('Cartelon'),
  ine('INE'),
  passport('Pasaporte'),
  driverLicense('Licencia de Conducir'),
  studentId('Credencial Estudiante'),
  employeeId('Credencial Empleado');

  const IdentificationType(this.displayName);

  final String displayName;

  static IdentificationType? fromString(String value) {
    for (var type in IdentificationType.values) {
      if (type.displayName.toLowerCase() == value.toLowerCase()) {
        return type;
      }
    }
    return null;
  }
}

/// Response wrapper for API calls involving visitor events
class VisitorEventResponse {
  final bool success;
  final String message;
  final VisitorEvent? data;
  final List<VisitorEvent>? events;
  final String? error;

  const VisitorEventResponse({
    required this.success,
    required this.message,
    this.data,
    this.events,
    this.error,
  });

  factory VisitorEventResponse.fromJson(Map<String, dynamic> json) {
    return VisitorEventResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? VisitorEvent.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      events: json['events'] != null
          ? (json['events'] as List)
                .map((e) => VisitorEvent.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      error: json['error'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.toJson(),
      'events': events?.map((e) => e.toJson()).toList(),
      'error': error,
    };
  }
}
