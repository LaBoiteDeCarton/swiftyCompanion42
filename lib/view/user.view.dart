import 'package:flutter/material.dart';
import 'package:swiftycompanion/services/user42.service.dart';

class UserView extends StatefulWidget {
  final Map<String, dynamic> userInfo;
  
  const UserView({
    super.key,
    required this.userInfo,
  });

  @override
  State<UserView> createState() => _UserViewState();
}

class _UserViewState extends State<UserView> {
  List<dynamic> usersProjects = [];
  List<dynamic> userCursus = [];
  bool _isLoadingProjects = false;
  bool _hasMoreProjects = true;
  int _currentPage = 1;
  final int _pageSize = 30;
  final ScrollController _scrollController = ScrollController();
  
  // Cursus selection
  int? _selectedCursusId;
  
  // Skills section toggle
  bool _isSkillsExpanded = false;

  @override
  void initState() {
    super.initState();
    _extractUserCursus();
    _fetchUserProjects();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (_hasMoreProjects && !_isLoadingProjects) {
        _loadMoreProjects();
      }
    }
  }

  void _extractUserCursus() {
    if (widget.userInfo['cursus_users'] != null) {
      final cursusUsers = widget.userInfo['cursus_users'] as List;
      userCursus = cursusUsers.map((cu) => cu['cursus']).toList();
    } else {
      userCursus = [];
    }
  }

  void _onCursusChanged(int? cursusId) {
    setState(() {
      _selectedCursusId = cursusId;
    });
    _fetchUserProjects();
  }

  void _fetchUserProjects() {
    setState(() {
      _currentPage = 1;
      _hasMoreProjects = true;
      usersProjects = [];
      _isLoadingProjects = true;
    });

    _loadProjectsPage(_currentPage);
  }

  void _loadMoreProjects() {
    if (!_isLoadingProjects && _hasMoreProjects) {
      _currentPage++;
      _loadProjectsPage(_currentPage);
    }
  }

  void _loadProjectsPage(int page) {
    final login = widget.userInfo['login'];
    if (login == null) {
      setState(() {
        _isLoadingProjects = false;
      });
      return;
    }

    setState(() {
      _isLoadingProjects = true;
    });

    // Call the User42Service with pagination parameters
    User42Service.getUserProjectsPaginated(
      login, 
      page: page, 
      pageSize: _pageSize,
    ).then((response) {
      setState(() {
        final newProjects = response['projects'] as List<dynamic>;
        final filteredProjects = _getFilteredProjects(newProjects);
        
        if (page == 1) {
          usersProjects = filteredProjects;
        } else {
          usersProjects.addAll(filteredProjects);
        }
        _hasMoreProjects = newProjects.length == _pageSize;
        _isLoadingProjects = false;
        _checkAndLoadMoreIfNeeded();
      });
    }).catchError((error) {
      setState(() {
        _isLoadingProjects = false;
      });
      print('Error fetching user projects page $page: $error');
    });
  }

  void _checkAndLoadMoreIfNeeded() {
    if (usersProjects.length < 3 && _hasMoreProjects && !_isLoadingProjects) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _loadMoreProjects();
      });
    }
  }

  List<dynamic> _getFilteredProjects(List<dynamic>? projectsList) {
    List<dynamic> projects = projectsList ?? [];
    
    if (_selectedCursusId != null) {
      projects = projects.where((project) {
        if (project['cursus_ids'] != null && project['cursus_ids'] is List) {
          final cursusIds = project['cursus_ids'] as List;
          return cursusIds.contains(_selectedCursusId);
        }
        return false;
      }).toList();
    }
    
    return projects;
  }

  String _getLevelForCursus() {
    if (widget.userInfo['cursus_users'] == null || 
        (widget.userInfo['cursus_users'] as List).isEmpty) {
      return 'Not available';
    }

    final cursusUsers = widget.userInfo['cursus_users'] as List;
    
    if (_selectedCursusId == null) {
      return cursusUsers.first['level']?.toString() ?? 'Not available';
    }
    
    final cursusUser = cursusUsers.firstWhere(
      (cu) => cu['cursus']['id'] == _selectedCursusId,
      orElse: () => null,
    );
    
    if (cursusUser != null) {
      return cursusUser['level']?.toString() ?? 'Not available';
    }
    
    return 'Not enrolled';
  }

  List<dynamic> _getSkillsForCursus() {
    if (widget.userInfo['cursus_users'] == null || 
        (widget.userInfo['cursus_users'] as List).isEmpty) {
      return [];
    }

    final cursusUsers = widget.userInfo['cursus_users'] as List;
    
    if (_selectedCursusId == null) {
      return [];
    }
    
    final cursusUser = cursusUsers.firstWhere(
      (cu) => cu['cursus']['id'] == _selectedCursusId,
      orElse: () => null,
    );
    
    if (cursusUser != null) {
      return cursusUser['skills'] ?? [];
    }
    
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              image: AssetImage('assets/scompanionLogowtbg2.png'),
              height: 50,
            ),
            Container(
              margin: EdgeInsets.only(right: 42),
              child: Text(
                'wifty Companion', 
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            )
          ]
        ),
        toolbarHeight: 80,
        backgroundColor: const Color.fromARGB(142, 40, 94, 174),
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Profile Image
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: widget.userInfo['image'] != null
                        ? NetworkImage(widget.userInfo['image']['versions']['small'])
                        : null,
                    backgroundColor: Colors.white,
                    child: widget.userInfo['image'] == null
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
                    widget.userInfo['displayname'] ?? 'Unknown User',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  
                  // User Login
                  Text(
                    '@${widget.userInfo['login'] ?? 'unknown'}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Cursus Selector
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Cursus:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int?>(
                        value: _selectedCursusId,
                        isExpanded: true,
                        dropdownColor: const Color(0xFF000E20),
                        style: const TextStyle(color: Colors.white),
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                        onChanged: (value) {
                          if (_selectedCursusId != value) _onCursusChanged(value);
                        },
                        items: [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text('All cursus'),
                          ),
                          ...userCursus.map<DropdownMenuItem<int?>>((cursus) {
                            return DropdownMenuItem<int?>(
                              value: cursus['id'],
                              child: Text(cursus['name']),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // User Information Cards
            _buildInfoCard('Email', widget.userInfo['email'] ?? 'Not available'),
            _buildInfoCard('Campus', widget.userInfo['campus']?.isNotEmpty == true 
                ? widget.userInfo['campus'][0]['name'] 
                : 'Not available'),
            if (_selectedCursusId != null) _buildInfoCard('Level', _getLevelForCursus()),
            _buildInfoCard('Wallet', '${widget.userInfo['wallet'] ?? 0} ₳'),
            _buildInfoCard('Correction Points', '${widget.userInfo['correction_point'] ?? 0}'),
            
            // Skills Section
            const SizedBox(height: 20),
            _buildSkillsSection(),
            

            // Projects Section
            const SizedBox(height: 20),
            const Text(
              'Recent Projects',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            if (usersProjects.isNotEmpty || _isLoadingProjects) ...[
              const SizedBox(height: 10),
              ..._buildProjectsList(),
              
              // Loading indicator for pagination
              if (_isLoadingProjects && usersProjects.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00BABC)),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              // Initial loading state
              if (_isLoadingProjects && usersProjects.isEmpty) ...[
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00BABC)),
                    ),
                  ),
                ),
              ],
              
              // End of projects indicator
              if (!_hasMoreProjects && usersProjects.isNotEmpty && !_isLoadingProjects) ...[
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'No more projects to load',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(20),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.1),
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
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsSection() {
    final skills = _getSkillsForCursus();
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(20),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with toggle button
          InkWell(
            onTap: () {
              setState(() {
                _isSkillsExpanded = !_isSkillsExpanded;
              });
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text(
                    'Skills',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF00BABC),
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  AnimatedRotation(
                    turns: _isSkillsExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Skills content
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: _isSkillsExpanded ? null : 0,
            child: _isSkillsExpanded
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: _selectedCursusId == null
                        ? Text(
                            'Select a cursus to view skills',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 14,
                            ),
                          )
                        : skills.isEmpty
                            ? Text(
                                'No skills available for this cursus',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 14,
                                ),
                              )
                            : Column(
                            children: skills.map((skill) {
                              final level = skill['level']?.toDouble() ?? 0.0;
                              final maxLevel = 20.0; // Assuming max skill level is 20
                              final percentage = (level / maxLevel).clamp(0.0, 1.0);
                              
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            skill['name'] ?? 'Unknown Skill',
                                            style: TextStyle(
                                              color: Colors.white.withValues(alpha: 0.9),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          level.toStringAsFixed(2),
                                          style: TextStyle(
                                            color: Colors.white.withValues(alpha: 0.7),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    LinearProgressIndicator(
                                      value: percentage,
                                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Color.lerp(
                                          Colors.red,
                                          Colors.green,
                                          percentage,
                                        )!,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildProjectsList() {
    final projects = usersProjects;
    
    return projects.map((project) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(20),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
        ),
        child: Row(
          children: [
            // Status indicator
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _getProjectStatusColor(project['status'], project['validated']),
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
                      color: Colors.white
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
                color: _getProjectStatusColor(project['status'], project['validated']),
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Color _getProjectStatusColor(String? status, bool? validated) {
    if (validated == true) {
      return Colors.green;
    }
    else if (validated == false) {
      return Colors.red;
    }
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