import 'package:flutter/material.dart';

import 'opportunity.dart';

/// Lifecycle of a volunteer application, mirroring the three card variants
/// in the "Mis Postulaciones" design.
enum ApplicationStatus {
  selected,
  pending,
  completed,
  history,
}

/// A student's application to an [Opportunity].
class Application {
  const Application({
    required this.opportunity,
    required this.status,
    required this.hours,
    required this.infoTitle,
    required this.infoSubtitle,
    required this.infoIcon,
    this.hoursLabel,
    this.canDownload = false,
  });

  final Opportunity opportunity;
  final ApplicationStatus status;
  final int hours;

  /// Headline of the context box (e.g. "Próxima sesión obligatoria").
  final String infoTitle;

  /// Supporting line of the context box.
  final String infoSubtitle;
  final IconData infoIcon;

  /// Reward pill label, e.g. "+15 hrs" / "10 hrs acreditadas".
  final String? hoursLabel;
  final bool canDownload;

  bool get isActive =>
      status == ApplicationStatus.selected || status == ApplicationStatus.pending;
}
