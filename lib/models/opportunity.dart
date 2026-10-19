import 'package:flutter/material.dart';

/// Volunteer cause categories shown as filter chips in the explore feed.
enum OpportunityCategory {
  all('Todos', Icons.grid_view_rounded, null),
  education('Educación', Icons.school, Icons.school),
  environment('Medio Ambiente', Icons.eco, Icons.forest),
  health('Salud', Icons.favorite, Icons.medical_services),
  community('Comunidad', Icons.groups, Icons.volunteer_activism),
  animals('Animales', Icons.pets, Icons.pets);

  const OpportunityCategory(this.label, this.chipIcon, this.badgeIcon);

  final String label;
  final IconData chipIcon;
  final IconData? badgeIcon;
}

/// Variant of the footer shown on the explore feed card.
enum OpportunityCardFooter { attendees, spotsLeft, startsSoon }

/// A perk granted to the volunteer (used in the "Qué te otorgamos" section).
class Benefit {
  const Benefit({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;
}

/// A volunteering opportunity surfaced in the explore feed and its detail page.
class Opportunity {
  const Opportunity({
    required this.id,
    required this.title,
    this.cardTitle,
    required this.organization,
    required this.category,
    required this.badgeLabel,
    required this.location,
    required this.hours,
    required this.imageUrl,
    required this.rating,
    required this.reviews,
    required this.modality,
    required this.schedule,
    required this.startInfo,
    required this.description,
    required this.requirements,
    required this.benefits,
    required this.spotsTotal,
    required this.spotsLeft,
    required this.attendees,
    this.cardFooter = OpportunityCardFooter.attendees,
    this.spotsNote,
    this.verified = true,
    this.address = '',
    this.sealId = '',
  });

  final String id;
  final String title;

  /// Shorter title used on the feed card (falls back to [title]).
  final String? cardTitle;
  final String organization;
  final OpportunityCategory category;

  /// Category badge text, e.g. "Educación · Escolar".
  final String badgeLabel;
  final String location;
  final int hours;
  final String imageUrl;
  final double rating;
  final int reviews;
  final String modality;
  final String schedule;
  final String startInfo;
  final String description;
  final List<String> requirements;
  final List<Benefit> benefits;
  final int spotsTotal;
  final int spotsLeft;
  final OpportunityCardFooter cardFooter;

  /// Small note shown on the card footer (spots left / starts soon).
  final String? spotsNote;

  /// Avatars of students already enrolled (shown in the overlapping stack).
  final List<String> attendees;
  final bool verified;
  final String address;
  final String sealId;

  double get spotsTakenRatio =>
      spotsTotal == 0 ? 0 : (spotsTotal - spotsLeft) / spotsTotal;
}
