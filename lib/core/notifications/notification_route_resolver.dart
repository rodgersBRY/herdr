enum NotificationRouteIntentType { mainTab, cowProfile }

class NotificationRouteIntent {
  final NotificationRouteIntentType type;
  final int? tabIndex;
  final String? cowId;

  const NotificationRouteIntent._({
    required this.type,
    this.tabIndex,
    this.cowId,
  });

  const NotificationRouteIntent.mainTab(int tabIndex)
    : this._(type: NotificationRouteIntentType.mainTab, tabIndex: tabIndex);

  const NotificationRouteIntent.cowProfile(String cowId)
    : this._(type: NotificationRouteIntentType.cowProfile, cowId: cowId);

  @override
  bool operator ==(Object other) {
    return other is NotificationRouteIntent &&
        other.type == type &&
        other.tabIndex == tabIndex &&
        other.cowId == cowId;
  }

  @override
  int get hashCode => Object.hash(type, tabIndex, cowId);

  @override
  String toString() {
    return 'NotificationRouteIntent(type: $type, tabIndex: $tabIndex, cowId: $cowId)';
  }
}

class NotificationRouteResolver {
  NotificationRouteResolver._();

  static NotificationRouteIntent? resolve(Map<String, dynamic> data) {
    final screen = data['screen']?.toString();

    switch (screen) {
      case 'alerts':
        return const NotificationRouteIntent.mainTab(0);
      case 'cows':
        return const NotificationRouteIntent.mainTab(1);
      case 'milk':
        return const NotificationRouteIntent.mainTab(2);
      case 'sales':
        return const NotificationRouteIntent.mainTab(3);
      case 'dashboard':
        return const NotificationRouteIntent.mainTab(4);
      case 'cow_profile':
        final cowId = data['cowId']?.toString();
        if (cowId == null || cowId.isEmpty) {
          return const NotificationRouteIntent.mainTab(1);
        }

        return NotificationRouteIntent.cowProfile(cowId);
      default:
        return null;
    }
  }
}
