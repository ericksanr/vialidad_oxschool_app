/// General Event model for the application
/// This can be used for various types of events in the system
class Event {
  final int? id;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String type;
  final Map<String, dynamic>? metadata;

  const Event({
    this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    this.updatedAt,
    required this.type,
    this.metadata,
  });

  /// Create Event from JSON
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as int?,
      title: json['title'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      type: json['type'] as String,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convert Event to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'type': type,
      'metadata': metadata,
    };
  }

  /// Create a copy with updated fields
  Event copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? type,
    Map<String, dynamic>? metadata,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      type: type ?? this.type,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Event &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.type == type;
  }

  @override
  int get hashCode {
    return Object.hash(id, title, description, createdAt, updatedAt, type);
  }

  @override
  String toString() {
    return 'Event(id: $id, title: $title, type: $type, createdAt: $createdAt)';
  }
}
