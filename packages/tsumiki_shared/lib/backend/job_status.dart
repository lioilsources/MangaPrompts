/// One step of a render job (`GET /api/jobs/{id}`).
class RenderStepStatus {
  const RenderStepStatus({
    required this.status,
    this.kind = 'image',
    this.error,
  });

  /// queued | running | done | error | skipped
  final String status;

  /// image | video
  final String kind;
  final String? error;

  bool get finished =>
      status == 'done' || status == 'error' || status == 'skipped';

  factory RenderStepStatus.fromJson(Map<String, dynamic> json) =>
      RenderStepStatus(
        status: json['status'] as String,
        kind: json['kind'] as String? ?? 'image',
        error: json['error'] as String?,
      );
}

/// Poll snapshot of a render job.
class RenderJobStatus {
  const RenderJobStatus({
    required this.status,
    required this.done,
    required this.total,
    required this.steps,
    this.error,
  });

  /// running | done | error
  final String status;
  final int done;
  final int total;
  final Map<String, RenderStepStatus> steps;
  final String? error;

  bool get finished => status == 'done' || status == 'error';

  factory RenderJobStatus.fromJson(Map<String, dynamic> json) =>
      RenderJobStatus(
        status: json['status'] as String,
        done: json['done'] as int? ?? 0,
        total: json['total'] as int? ?? 0,
        error: json['error'] as String?,
        steps: {
          for (final e in (json['steps'] as Map? ?? const {}).entries)
            e.key as String: RenderStepStatus.fromJson((e.value as Map).cast()),
        },
      );
}

/// The accepted render (`POST /api/render` 200 body).
class RenderJob {
  const RenderJob({
    required this.jobId,
    required this.stepsTotal,
    required this.cost,
  });

  final String jobId;
  final int stepsTotal;
  final int cost;

  factory RenderJob.fromJson(Map<String, dynamic> json) => RenderJob(
    jobId: json['job_id'] as String,
    stepsTotal: json['steps_total'] as int,
    cost: json['cost'] as int? ?? json['steps_total'] as int,
  );
}
