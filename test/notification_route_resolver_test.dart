import 'package:cattle_manager/core/notifications/notification_route_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotificationRouteResolver', () {
    test('opens alerts for alert payloads', () {
      final intent = NotificationRouteResolver.resolve({'screen': 'alerts'});

      expect(intent, const NotificationRouteIntent.mainTab(0));
    });

    test('opens sales for sales payloads', () {
      final intent = NotificationRouteResolver.resolve({'screen': 'sales'});

      expect(intent, const NotificationRouteIntent.mainTab(3));
    });

    test('opens cow profile when cow id is present', () {
      final intent = NotificationRouteResolver.resolve({
        'screen': 'cow_profile',
        'cowId': 'cow-1',
      });

      expect(intent, const NotificationRouteIntent.cowProfile('cow-1'));
    });

    test('falls back to cows tab when cow profile has no cow id', () {
      final intent = NotificationRouteResolver.resolve({
        'screen': 'cow_profile',
      });

      expect(intent, const NotificationRouteIntent.mainTab(1));
    });

    test('returns null for unknown screens', () {
      final intent = NotificationRouteResolver.resolve({'screen': 'unknown'});

      expect(intent, isNull);
    });
  });
}
