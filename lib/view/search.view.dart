import 'package:flutter/material.dart';
import 'package:swiftycompanion/services/user42.service.dart';
import 'user.view.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearch() {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });
    
    final login = _searchController.text.trim();
    if (login.isNotEmpty) {
      User42Service.getUserByLogin(login).then((userData) {
        if (userData != null) {
          print('User data found for login: $login');
          // Navigate to home screen with user data
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => UserView(userInfo: userData),
            ),
          );
        }
        else {
          print('No user found with login: $login');
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No user found with login: $login'),
              backgroundColor: const Color.fromARGB(255, 128, 139, 80),
            )
          );
        }
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }).catchError((error) {
        print('Error fetching user data: $error');
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Network error fetching user data'),
              backgroundColor: const Color.fromARGB(255, 128, 139, 80),
          )
        );
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          spacing: 42.0,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
              Image(
                  image: AssetImage("assets/scompanionLogowtbg.png"),
                  fit: BoxFit.contain,
                  height: MediaQuery.of(context).size.height * 0.4,
                ),
              Column(
                spacing: 16.0,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      constraints: const BoxConstraints(
                        maxWidth: 400, // Maximum width for the search input
                      ),
                      child: TextField(
                      maxLength: 10,
                      controller: _searchController,
                      focusNode: _focusNode,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        enabled: !_isLoading,
                        hintText: 'Enter 42 login...',
                        hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 16,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.white,
                        ),
                        suffixIcon: IconButton(
                          icon: _isLoading 
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                              ),
                          onPressed: _isLoading ? null : _onSearch,
                        ),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: const BorderSide(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _onSearch(),
                    ),
                  ),
                ),
                  Text(
                    'Search for 42 student profiles',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      )
    );
  }
}