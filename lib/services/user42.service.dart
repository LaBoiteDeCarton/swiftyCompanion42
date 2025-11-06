import 'api42.service.dart';

class User42Service {
  /// Search for a user by login
  static Future<Map<String, dynamic>?> getUserByLogin(String login) async {
    try {
      final response = await Api42Service.get('/users/$login');
      
      // Handle 404 - user not found
      if (response['notFound'] == true) {
        return null;
      }
      return response['data'];
    } catch (e) {
      print('Error fetching user $login: $e');
      throw(e);
    }
  }

  /// Get user's projects with pagination
  static Future<Map<String, dynamic>> getUserProjectsPaginated(
    String login, {
    int page = 1,
    int pageSize = 30,
  }) async {
    try {
      final params = <String, dynamic>{
        'page[number]': page,
        'page[size]': pageSize,
      };
      
      final response = await Api42Service.get('/users/$login/projects_users', queryParams: params);
      
      // Handle 404 - user not found or no projects
      if (response['notFound'] == true) {
        return {
          'projects': <dynamic>[],
          'pagination': response['pagination'],
        };
      }
      
      return {
        'projects': response['data'],
        'pagination': response['pagination'],
      };
    } catch (e) {
      print('Error fetching paginated projects for user $login: $e');
      return {
        'projects': <dynamic>[],
        'pagination': null,
      };
    }
  }
}