
enum WellnessSessionType {
  meditation,
  breathing,
  workout,
  stretching,
  mindfulness,
  relaxation,
  // New session types
  yoga,           // Structured yoga flows
  pilates,        // Core strengthening
  cardio,         // Heart rate focused
  strength,       // Resistance training
  mobility,       // Joint mobility
  recovery,       // Post-workout recovery
  sleep,          // Sleep preparation
  focus,          // Concentration enhancement
  creativity,     // Creative thinking
  gratitude,      // Gratitude practices
}

enum SessionDifficulty {
  beginner,
  intermediate,
  advanced,
}

enum SessionStatus {
  notStarted,
  inProgress,
  paused,
  completed,
  skipped,
}

enum CueType {
  instruction,
  motivation,
  transition,
  warning,
  completion,
  breathingCue,
  positionChange,
  restPeriod,
}

class SessionCue {
  final Duration timestamp;
  final String message;
  final CueType type;
  final Map<String, dynamic>? data;

  const SessionCue({
    required this.timestamp,
    required this.message,
    required this.type,
    this.data,
  });

  SessionCue copyWith({
    Duration? timestamp,
    String? message,
    CueType? type,
    Map<String, dynamic>? data,
  }) {
    return SessionCue(
      timestamp: timestamp ?? this.timestamp,
      message: message ?? this.message,
      type: type ?? this.type,
      data: data ?? this.data,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.inSeconds,
      'message': message,
      'type': type.name,
      'data': data,
    };
  }

  factory SessionCue.fromJson(Map<String, dynamic> json) {
    return SessionCue(
      timestamp: Duration(seconds: json['timestamp'] as int),
      message: json['message'] as String,
      type: CueType.values.firstWhere((type) => type.name == json['type']),
      data: json['data'] as Map<String, dynamic>?,
    );
  }
}

class WellnessSession {
  final String id;
  final String title;
  final String description;
  final WellnessSessionType type;
  final Duration duration;
  final SessionDifficulty difficulty;
  final String? audioUrl;
  final String? videoUrl;
  final String? imageUrl;
  final List<String> instructions;
  final List<String> benefits;
  final Map<String, dynamic> metadata;
  final bool isPremium;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // New enhanced fields
  final List<String> equipment;           // Required equipment
  final String? instructor;               // Session instructor
  final List<String> targetAreas;         // Body areas or mental aspects
  final int? caloriesBurned;             // Estimated calories
  final List<String> prerequisites;       // Required prior sessions
  final Map<String, dynamic> analytics;   // Session analytics data
  final bool isProgressive;              // Part of a program
  final int? seriesOrder;                // Order in series
  final String? musicUrl;                // Background music
  final List<SessionCue> cues;           // Timed cues during session
  final String? programId;               // Associated program ID
  final Duration? preparationTime;       // Setup time needed
  final Duration? cooldownTime;          // Cool down period

  const WellnessSession({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.duration,
    this.difficulty = SessionDifficulty.beginner,
    this.audioUrl,
    this.videoUrl,
    this.imageUrl,
    this.instructions = const [],
    this.benefits = const [],
    this.metadata = const {},
    this.isPremium = false,
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
    // New fields with defaults
    this.equipment = const [],
    this.instructor,
    this.targetAreas = const [],
    this.caloriesBurned,
    this.prerequisites = const [],
    this.analytics = const {},
    this.isProgressive = false,
    this.seriesOrder,
    this.musicUrl,
    this.cues = const [],
    this.programId,
    this.preparationTime,
    this.cooldownTime,
  });

  WellnessSession copyWith({
    String? id,
    String? title,
    String? description,
    WellnessSessionType? type,
    Duration? duration,
    SessionDifficulty? difficulty,
    String? audioUrl,
    String? videoUrl,
    String? imageUrl,
    List<String>? instructions,
    List<String>? benefits,
    Map<String, dynamic>? metadata,
    bool? isPremium,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    // New fields
    List<String>? equipment,
    String? instructor,
    List<String>? targetAreas,
    int? caloriesBurned,
    List<String>? prerequisites,
    Map<String, dynamic>? analytics,
    bool? isProgressive,
    int? seriesOrder,
    String? musicUrl,
    List<SessionCue>? cues,
    String? programId,
    Duration? preparationTime,
    Duration? cooldownTime,
  }) {
    return WellnessSession(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      duration: duration ?? this.duration,
      difficulty: difficulty ?? this.difficulty,
      audioUrl: audioUrl ?? this.audioUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      instructions: instructions ?? this.instructions,
      benefits: benefits ?? this.benefits,
      metadata: metadata ?? this.metadata,
      isPremium: isPremium ?? this.isPremium,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      // New fields
      equipment: equipment ?? this.equipment,
      instructor: instructor ?? this.instructor,
      targetAreas: targetAreas ?? this.targetAreas,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      prerequisites: prerequisites ?? this.prerequisites,
      analytics: analytics ?? this.analytics,
      isProgressive: isProgressive ?? this.isProgressive,
      seriesOrder: seriesOrder ?? this.seriesOrder,
      musicUrl: musicUrl ?? this.musicUrl,
      cues: cues ?? this.cues,
      programId: programId ?? this.programId,
      preparationTime: preparationTime ?? this.preparationTime,
      cooldownTime: cooldownTime ?? this.cooldownTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'duration': duration.inSeconds,
      'difficulty': difficulty.name,
      'audioUrl': audioUrl,
      'videoUrl': videoUrl,
      'imageUrl': imageUrl,
      'instructions': instructions,
      'benefits': benefits,
      'metadata': metadata,
      'isPremium': isPremium,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      // New fields
      'equipment': equipment,
      'instructor': instructor,
      'targetAreas': targetAreas,
      'caloriesBurned': caloriesBurned,
      'prerequisites': prerequisites,
      'analytics': analytics,
      'isProgressive': isProgressive,
      'seriesOrder': seriesOrder,
      'musicUrl': musicUrl,
      'cues': cues.map((cue) => cue.toJson()).toList(),
      'programId': programId,
      'preparationTime': preparationTime?.inSeconds,
      'cooldownTime': cooldownTime?.inSeconds,
    };
  }

  factory WellnessSession.fromJson(Map<String, dynamic> json) {
    return WellnessSession(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: WellnessSessionType.values.firstWhere((type) => type.name == json['type']),
      duration: Duration(seconds: json['duration'] as int),
      difficulty: SessionDifficulty.values.firstWhere((diff) => diff.name == json['difficulty']),
      audioUrl: json['audioUrl'] as String?,
      videoUrl: json['videoUrl'] as String?,
      imageUrl: json['imageUrl'] as String?,
      instructions: (json['instructions'] as List<dynamic>).cast<String>(),
      benefits: (json['benefits'] as List<dynamic>).cast<String>(),
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
      isPremium: json['isPremium'] as bool? ?? false,
      tags: (json['tags'] as List<dynamic>).cast<String>(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      // New fields
      equipment: (json['equipment'] as List<dynamic>?)?.cast<String>() ?? [],
      instructor: json['instructor'] as String?,
      targetAreas: (json['targetAreas'] as List<dynamic>?)?.cast<String>() ?? [],
      caloriesBurned: json['caloriesBurned'] as int?,
      prerequisites: (json['prerequisites'] as List<dynamic>?)?.cast<String>() ?? [],
      analytics: json['analytics'] as Map<String, dynamic>? ?? {},
      isProgressive: json['isProgressive'] as bool? ?? false,
      seriesOrder: json['seriesOrder'] as int?,
      musicUrl: json['musicUrl'] as String?,
      cues: (json['cues'] as List<dynamic>?)
          ?.map((cue) => SessionCue.fromJson(cue as Map<String, dynamic>))
          .toList() ?? [],
      programId: json['programId'] as String?,
      preparationTime: json['preparationTime'] != null
          ? Duration(seconds: json['preparationTime'] as int)
          : null,
      cooldownTime: json['cooldownTime'] != null
          ? Duration(seconds: json['cooldownTime'] as int)
          : null,
    );
  }

  // Helper methods
  String get typeLabel {
    switch (type) {
      case WellnessSessionType.meditation:
        return 'Meditation';
      case WellnessSessionType.breathing:
        return 'Breathing';
      case WellnessSessionType.workout:
        return 'Workout';
      case WellnessSessionType.stretching:
        return 'Stretching';
      case WellnessSessionType.mindfulness:
        return 'Mindfulness';
      case WellnessSessionType.relaxation:
        return 'Relaxation';
      case WellnessSessionType.yoga:
        return 'Yoga';
      case WellnessSessionType.pilates:
        return 'Pilates';
      case WellnessSessionType.cardio:
        return 'Cardio';
      case WellnessSessionType.strength:
        return 'Strength';
      case WellnessSessionType.mobility:
        return 'Mobility';
      case WellnessSessionType.recovery:
        return 'Recovery';
      case WellnessSessionType.sleep:
        return 'Sleep';
      case WellnessSessionType.focus:
        return 'Focus';
      case WellnessSessionType.creativity:
        return 'Creativity';
      case WellnessSessionType.gratitude:
        return 'Gratitude';
    }
  }

  String get difficultyLabel {
    switch (difficulty) {
      case SessionDifficulty.beginner:
        return 'Beginner';
      case SessionDifficulty.intermediate:
        return 'Intermediate';
      case SessionDifficulty.advanced:
        return 'Advanced';
    }
  }

  String get durationFormatted {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    if (minutes > 0) {
      return seconds > 0 ? '${minutes}m ${seconds}s' : '${minutes}m';
    }
    return '${seconds}s';
  }

  bool get hasMedia => audioUrl != null || videoUrl != null;
  
  // New helper methods for enhanced functionality
  bool get requiresEquipment => equipment.isNotEmpty;
  
  bool get hasInstructor => instructor != null && instructor!.isNotEmpty;
  
  bool get hasCues => cues.isNotEmpty;
  
  bool get isPartOfProgram => programId != null;
  
  String get equipmentList => equipment.join(', ');
  
  String get targetAreasList => targetAreas.join(', ');
  
  Duration get totalDuration {
    Duration total = duration;
    if (preparationTime != null) total += preparationTime!;
    if (cooldownTime != null) total += cooldownTime!;
    return total;
  }
  
  String get totalDurationFormatted {
    final minutes = totalDuration.inMinutes;
    final seconds = totalDuration.inSeconds % 60;
    if (minutes > 0) {
      return seconds > 0 ? '${minutes}m ${seconds}s' : '${minutes}m';
    }
    return '${seconds}s';
  }
  
  List<SessionCue> getCuesForTimeRange(Duration start, Duration end) {
    return cues.where((cue) =>
      cue.timestamp >= start && cue.timestamp <= end
    ).toList();
  }
  
  SessionCue? getNextCue(Duration currentTime) {
    final upcomingCues = cues.where((cue) => cue.timestamp > currentTime).toList();
    if (upcomingCues.isEmpty) return null;
    upcomingCues.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return upcomingCues.first;
  }
  
  bool get isPhysicalActivity {
    return [
      WellnessSessionType.workout,
      WellnessSessionType.yoga,
      WellnessSessionType.pilates,
      WellnessSessionType.cardio,
      WellnessSessionType.strength,
      WellnessSessionType.stretching,
      WellnessSessionType.mobility,
    ].contains(type);
  }
  
  bool get isMentalActivity {
    return [
      WellnessSessionType.meditation,
      WellnessSessionType.mindfulness,
      WellnessSessionType.breathing,
      WellnessSessionType.focus,
      WellnessSessionType.creativity,
      WellnessSessionType.gratitude,
      WellnessSessionType.sleep,
    ].contains(type);
  }
}

class SessionProgress {
  final String id;
  final String sessionId;
  final String userId;
  final SessionStatus status;
  final Duration progressTime;
  final DateTime startedAt;
  final DateTime? completedAt;
  final DateTime? pausedAt;
  final int? rating; // 1-5 stars
  final String? feedback;
  final Map<String, dynamic> sessionData;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SessionProgress({
    required this.id,
    required this.sessionId,
    required this.userId,
    this.status = SessionStatus.notStarted,
    this.progressTime = Duration.zero,
    required this.startedAt,
    this.completedAt,
    this.pausedAt,
    this.rating,
    this.feedback,
    this.sessionData = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  SessionProgress copyWith({
    String? id,
    String? sessionId,
    String? userId,
    SessionStatus? status,
    Duration? progressTime,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? pausedAt,
    int? rating,
    String? feedback,
    Map<String, dynamic>? sessionData,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SessionProgress(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      progressTime: progressTime ?? this.progressTime,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      pausedAt: pausedAt ?? this.pausedAt,
      rating: rating ?? this.rating,
      feedback: feedback ?? this.feedback,
      sessionData: sessionData ?? this.sessionData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionId': sessionId,
      'userId': userId,
      'status': status.name,
      'progressTime': progressTime.inSeconds,
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'pausedAt': pausedAt?.toIso8601String(),
      'rating': rating,
      'feedback': feedback,
      'sessionData': sessionData,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory SessionProgress.fromJson(Map<String, dynamic> json) {
    return SessionProgress(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      userId: json['userId'] as String,
      status: SessionStatus.values.firstWhere((status) => status.name == json['status']),
      progressTime: Duration(seconds: json['progressTime'] as int),
      startedAt: DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt'] as String) : null,
      pausedAt: json['pausedAt'] != null ? DateTime.parse(json['pausedAt'] as String) : null,
      rating: json['rating'] as int?,
      feedback: json['feedback'] as String?,
      sessionData: json['sessionData'] as Map<String, dynamic>? ?? {},
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  bool get isCompleted => status == SessionStatus.completed;
  bool get isInProgress => status == SessionStatus.inProgress;
  bool get isPaused => status == SessionStatus.paused;

  double get progressPercentage {
    if (sessionData['totalDuration'] != null) {
      final totalDuration = Duration(seconds: sessionData['totalDuration'] as int);
      return (progressTime.inSeconds / totalDuration.inSeconds).clamp(0.0, 1.0);
    }
    return 0.0;
  }
}