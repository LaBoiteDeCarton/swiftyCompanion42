// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:swiftycompanion/models/user_profile.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    dotenv.testLoad(fileInput: '''
API_UID=test_uid
API_SECRET=test_secret
REDIRECT_URI=com.swiftycompanion://callback
API_BASE_URL=https://api.intra.42.fr
''');
  });

  group('User Profile Model Tests', () {
    test('User42Profile should parse JSON correctly', () {
      final Map<String, dynamic> testJson = {
        'login': 'testuser',
        'displayname': 'Test User',
        'email': 'test@student.42.fr',
        'wallet': 100,
        'correction_point': 5,
        'image': {
          'versions': {
            'large': 'http://example.com/image.jpg'
          }
        },
        'campus': [
          {'name': 'Paris'}
        ],
        'cursus_users': [
          {'level': 3.14}
        ],
        'projects_users': [
          {
            'id': 1,
            'status': 'finished',
            'final_mark': 125,
            'project': {
              'name': 'libft'
            }
          }
        ]
      };

      final user = User42Profile.fromJson(testJson);

      expect(user.login, equals('testuser'));
      expect(user.displayName, equals('Test User'));
      expect(user.email, equals('test@student.42.fr'));
      expect(user.wallet, equals(100));
      expect(user.correctionPoints, equals(5));
      expect(user.imageUrl, equals('http://example.com/image.jpg'));
      expect(user.campus, equals('Paris'));
      expect(user.level, equals(3.14));
      expect(user.recentProjects.length, equals(1));
      expect(user.recentProjects[0].name, equals('libft'));
      expect(user.recentProjects[0].status, equals('finished'));
      expect(user.recentProjects[0].finalMark, equals(125));
    });

    test('User42Profile should handle missing fields gracefully', () {
      final Map<String, dynamic> testJson = {
        'login': 'testuser',
      };

      final user = User42Profile.fromJson(testJson);

      expect(user.login, equals('testuser'));
      expect(user.displayName, equals('testuser')); // fallback to login
      expect(user.email, equals(''));
      expect(user.wallet, equals(0));
      expect(user.correctionPoints, equals(0));
      expect(user.imageUrl, isNull);
      expect(user.campus, isNull);
      expect(user.level, isNull);
      expect(user.recentProjects, isEmpty);
    });
  });

  group('Project42 Model Tests', () {
    test('Project42 should parse JSON correctly', () {
      final Map<String, dynamic> testJson = {
        'id': 123,
        'status': 'finished',
        'final_mark': 125,
        'project': {
          'name': 'libft'
        }
      };

      final project = Project42.fromJson(testJson);

      expect(project.id, equals(123));
      expect(project.status, equals('finished'));
      expect(project.finalMark, equals(125));
      expect(project.name, equals('libft'));
    });

    test('Project42 should handle missing fields gracefully', () {
      final Map<String, dynamic> testJson = {};

      final project = Project42.fromJson(testJson);

      expect(project.id, equals(0));
      expect(project.status, equals('unknown'));
      expect(project.finalMark, isNull);
      expect(project.name, equals('Unknown Project'));
    });
  });
}
