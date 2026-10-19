import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/application.dart';
import '../models/opportunity.dart';
import '../models/student_profile.dart';

/// In-memory application state shared across every screen.
///
/// There is no backend: favorites, applications and filters live for the
/// duration of the session and drive every screen through [AppScope].
class AppState extends ChangeNotifier {
  AppState({List<Application>? applications})
      : _applications = List.of(applications ?? kInitialApplications);

  final StudentProfile _profile = kStudentProfile;
  final List<Application> _applications;
  final Set<String> _favoriteIds = {};

  String _searchQuery = '';
  OpportunityCategory _selectedCategory = OpportunityCategory.all;

  StudentProfile get profile => _profile;
  List<Application> get applications => List.unmodifiable(_applications);
  String get searchQuery => _searchQuery;
  OpportunityCategory get selectedCategory => _selectedCategory;

  int get activeCount => _applications
      .where((a) => a.status == ApplicationStatus.selected ||
          a.status == ApplicationStatus.pending)
      .length;

  int get completedCount =>
      _applications.where((a) => a.status == ApplicationStatus.completed).length;

  int get historyCount =>
      _applications.where((a) => a.status == ApplicationStatus.history).length;

  /// Applications filtered by the tab selected in "Mis Postulaciones".
  List<Application> applicationsFor(ApplicationStatus? status) =>
      status == null
          ? _applications
          : _applications.where((a) => a.status == status).toList();

  /// Featured opportunities after applying search + category filters.
  List<Opportunity> get filteredOpportunities {
    final query = _searchQuery.trim().toLowerCase();
    return kFeaturedOpportunities.where((o) {
      final matchesCategory = _selectedCategory == OpportunityCategory.all ||
          o.category == _selectedCategory;
      final matchesQuery = query.isEmpty ||
          o.title.toLowerCase().contains(query) ||
          o.organization.toLowerCase().contains(query) ||
          (o.cardTitle ?? '').toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();
  }

  bool isFavorite(String id) => _favoriteIds.contains(id);

  void toggleFavorite(String id) {
    if (!_favoriteIds.add(id)) {
      _favoriteIds.remove(id);
    }
    notifyListeners();
  }

  void setSearchQuery(String value) {
    if (_searchQuery == value) return;
    _searchQuery = value;
    notifyListeners();
  }

  void setCategory(OpportunityCategory category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    notifyListeners();
  }

  bool hasApplied(Opportunity opportunity) =>
      _applications.any((a) => a.opportunity.id == opportunity.id);

  /// Registers the student in [opportunity]. Returns `false` when there is
  /// already an active application for it.
  bool apply(Opportunity opportunity) {
    if (hasApplied(opportunity)) return false;

    _applications.insert(
      0,
      Application(
        opportunity: opportunity,
        status: ApplicationStatus.pending,
        hours: opportunity.hours,
        hoursLabel: '+${opportunity.hours} hrs proyectadas',
        infoTitle: 'Postulación enviada',
        infoSubtitle: 'En revisión por el equipo coordinador',
        infoIcon: Icons.hourglass_top,
      ),
    );
    notifyListeners();
    return true;
  }

  /// Withdraws the student from [application]. Returns `false` when it is no
  /// longer present in the list.
  bool cancelApplication(Application application) {
    final index = _applications.indexWhere(
      (a) => a.opportunity.id == application.opportunity.id,
    );
    if (index == -1) return false;
    _applications.removeAt(index);
    notifyListeners();
    return true;
  }
}

/// Exposes the [AppState] to the widget tree via an [InheritedNotifier], so
/// any descendant can call `AppScope.of(context)` and rebuild on change.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({
    super.key,
    required AppState state,
    required super.child,
  }) : super(notifier: state);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope was not found in the widget tree.');
    return scope!.notifier!;
  }
}
