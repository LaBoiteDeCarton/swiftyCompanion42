import 'package:flutter/material.dart';
import 'package:particles_network/particles_network.dart';
import '../services/oauth_service.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await OAuthService.getCurrentUser();
      if (mounted) {
        setState(() {
          _userProfile = profile;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    try {
      await OAuthService.logout();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
  children: [
    ParticleNetwork(
          touchActivation: true, // to Activate touch
          particleCount: 160, // Number of particles
          maxSpeed: 0.5, // Maximum particle speed
          maxSize: 2.5, // Maximum particle size
          lineDistance: 120, // Maximum distance for connecting lines
          particleColor: const Color(0xFF013154),
          lineColor: const Color.fromARGB(255, 6, 52, 97),
          touchColor: const Color.fromARGB(255, 12, 71, 129),
        ),
    Scaffold(
      backgroundColor: const Color.fromARGB(0, 40, 94, 174),
      appBar: AppBar(
        title: Row(
          children : [
            Image(
              image: AssetImage('assets/scompanionLogowtbg2.png'),
              height: 50,
              ),
            Text('wifty Companion', 
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
            ),),
          ]
        ),
        toolbarHeight: 80,
        backgroundColor: const Color.fromARGB(142, 40, 94, 174),
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
        actions: [
          IconButton(
            onPressed: _handleLogout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color.fromARGB(255, 17, 73, 73)),
              ),
            )
          : _userProfile == null
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Failed to load user profile',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Header
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        // decoration: BoxDecoration(
                        //   gradient: const LinearGradient(
                        //     colors: [Color(0xFF00BABC), Color(0xFF00A3A5)],
                        //   ),
                        //   borderRadius: BorderRadius.circular(15),
                        // ),
                        child: Column(
                          children: [
                            // Profile Image
                            CircleAvatar(
                              radius: 50,
                              backgroundImage: _userProfile!['image'] != null
                                  ? NetworkImage(_userProfile!['image']['versions']['small'])
                                  : null,
                              backgroundColor: Colors.white,
                              child: _userProfile!['image'] == null
                                  ? const Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Color(0xFF00BABC),
                                    )
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            
                            // User Name
                            Text(
                              _userProfile!['displayname'] ?? 'Unknown User',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            
                            // User Login
                            Text(
                              '@${_userProfile!['login'] ?? 'unknown'}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // User Information Cards
                      _buildInfoCard('Email', _userProfile!['email'] ?? 'Not available'),
                      _buildInfoCard('Campus', _userProfile!['campus']?.isNotEmpty == true 
                          ? _userProfile!['campus'][0]['name'] 
                          : 'Not available'),
                      _buildInfoCard('Level', _userProfile!['cursus_users']?.isNotEmpty == true 
                          ? (_userProfile!['cursus_users'][0]['level']?.toString() ?? 'Not available')
                          : 'Not available'),
                      _buildInfoCard('Wallet', '${_userProfile!['wallet'] ?? 0} ₳'),
                      _buildInfoCard('Correction Points', '${_userProfile!['correction_point'] ?? 0}'),
                      
                      // Projects Section
                      if (_userProfile!['projects_users'] != null && 
                          _userProfile!['projects_users'].isNotEmpty) ...[
                        const SizedBox(height: 20),
                        const Text(
                          'Recent Projects',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ..._buildProjectsList(),
                      ],
                    ],
                  ),
                ),
      )]
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title:',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF00BABC),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildProjectsList() {
    List<dynamic> projects = _userProfile!['projects_users'];
    projects.sort((a, b) => b['id'].compareTo(a['id'])); // Sort by newest first
    
    return projects.map((project) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            // Status indicator
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _getProjectStatusColor(project['status']),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            
            // Project info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project['project']['name'] ?? 'Unknown Project',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (project['final_mark'] != null)
                    Text(
                      'Score: ${project['final_mark']}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            
            // Status text
            Text(
              project['status'] ?? 'Unknown',
              style: TextStyle(
                color: _getProjectStatusColor(project['status']),
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Color _getProjectStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'finished':
        return Colors.green;
      case 'in_progress':
        return Colors.orange;
      case 'searching_a_group':
        return Colors.blue;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}