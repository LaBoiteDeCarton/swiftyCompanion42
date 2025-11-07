import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:particles_network/particles_network.dart';
import 'package:swiftycompanion/view/search.view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Swifty Companion',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 41, 123, 74),
          primary: const Color.fromARGB(255, 9, 115, 92),
        ),
        useMaterial3: true,
      ),
      builder:(context, child) {
        return Container(
          color: const Color(0xFF000E20),
          child: Stack(
            children: [
              
              ParticleNetwork(
              touchActivation: false, // to Activate touch
              particleCount: 120, // Number of particles
              maxSpeed: 0.5, // Maximum particle speed
              maxSize: 2.5, // Maximum particle size
              lineDistance: 80, // Maximum distance for connecting lines
              particleColor: const Color.fromARGB(255, 2, 62, 105),
              lineColor: const Color.fromARGB(255, 6, 52, 97),
              touchColor: const Color.fromARGB(255, 12, 71, 129),
            ),
            child!],
          ),
        );
      },
      home: Scaffold(
        backgroundColor: Colors.transparent,
        body: SearchView(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const SearchView();
  }
}


