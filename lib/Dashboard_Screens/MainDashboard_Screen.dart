import 'package:flutter/material.dart';
import 'package:g21285889_daniru_gihen/Dashboard_Screens/Insights_Screen.dart';
import 'package:g21285889_daniru_gihen/Dashboard_Screens/Profile_Screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Dashboard_Screen(),
    );
  }
}

class Dashboard_Screen extends StatefulWidget {
  const Dashboard_Screen({super.key});

  @override
  _Dashboard_ScreenState createState() => _Dashboard_ScreenState();
}

class _Dashboard_ScreenState extends State<Dashboard_Screen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(), // Main Dashboard
    InsightsScreen(), // Insights Screen
    ProfileScreen(), // Profile screen
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update selected index
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFCCF4E6),
      body: IndexedStack(
        index: _selectedIndex, // Show the selected screen
        children: _screens, // All screens are kept alive
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black87,
        unselectedItemColor: Colors.black54,
        currentIndex: _selectedIndex, // Highlight selected tab
        onTap: _onItemTapped, // Handle navigation
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Insights"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _targetSugarController = TextEditingController();
  String _sugarContent = '';
  String _barcodeSugarContent = '';
  bool _isLoading = false;
  bool _isBarcodeLoading = false;
  double? _targetSugar; // Starts as null until user sets it
  double _consumedSugar = 0.0; // Starts at 0
  bool _targetSet = false; // Tracks if target has been set

  @override
  void initState() {
    super.initState();
    _loadSugarData(); // Load data from Firestore when the screen initializes
  }

  // Load sugar data from Firestore
  Future<void> _loadSugarData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final doc = await docRef.get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _targetSugar = data['targetSugar']?.toDouble();
          _consumedSugar = data['consumedSugar']?.toDouble() ?? 0.0;
          _targetSet = _targetSugar != null; // Target is set if it exists in Firestore
        });
      }
    }
  }

  // Save sugar data to Firestore
  Future<void> _saveSugarData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      await docRef.set({
        'targetSugar': _targetSugar,
        'consumedSugar': _consumedSugar,
      }, SetOptions(merge: true)); // Merge to avoid overwriting other fields
    }
  }

  Future<void> _searchProductByName() async {
    final productName = _productNameController.text.trim();
    if (productName.isEmpty) {
      setState(() {
        _sugarContent = 'Please enter a product name';
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _sugarContent = '';
    });
    try {
      final encodedName = Uri.encodeComponent(productName);
      final url = Uri.parse('https://world.openfoodfacts.org/cgi/search.pl?search_terms=$encodedName&search_simple=1&action=process&json=1');

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['products'] != null && data['products'].length > 0) {
          final product = data['products'][0];
          if (product['nutriments'] != null && product['nutriments']['sugars_100g'] != null) {
            final sugar = product['nutriments']['sugars_100g'].toDouble();
            final productNameFound = product['product_name'] ?? productName;
            setState(() {
              _sugarContent = 'Sugar Content for $productNameFound: $sugar g per 100g';
              if (_targetSet) {
                _consumedSugar += sugar; // Add sugar (assuming 100g serving)
                _saveSugarData(); // Save to Firestore
              }
            });
          } else {
            setState(() {
              _sugarContent = 'Sugar content not found for this product';
            });
          }
        } else {
          setState(() {
            _sugarContent = 'No products found with that name';
          });
        }
      } else {
        setState(() {
          _sugarContent = 'Error: Failed to fetch product data (Status: ${response.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        _sugarContent = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchSugarContentByBarcode() async {
    final barcode = _barcodeController.text.trim();
    if (barcode.isEmpty) {
      setState(() {
        _barcodeSugarContent = 'Please enter a barcode';
      });
      return;
    }
    setState(() {
      _isBarcodeLoading = true;
      _barcodeSugarContent = '';
    });
    try {
      final url = Uri.parse('https://world.openfoodfacts.org/api/v2/product/$barcode.json');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 1 && data['product'] != null) {
          final nutriments = data['product']['nutriments'];
          if (nutriments != null && nutriments.containsKey('sugars_100g')) {
            final sugar = nutriments['sugars_100g'].toDouble();
            final productName = data['product']['product_name'] ?? 'Unknown Product';
            setState(() {
              _barcodeSugarContent = 'Sugar Content for $productName: $sugar g per 100g';
              if (_targetSet) {
                _consumedSugar += sugar; // Add sugar (assuming 100g serving)
                _saveSugarData(); // Save to Firestore
              }
            });
          } else {
            setState(() {
              _barcodeSugarContent = 'Sugar content not found for this barcode';
            });
          }
        } else {
          setState(() {
            _barcodeSugarContent = 'Product not found for this barcode';
          });
        }
      } else {
        setState(() {
          _barcodeSugarContent = 'Error: Failed to fetch product data (Status: ${response.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        _barcodeSugarContent = 'Error: $e';
      });
    } finally {
      setState(() {
        _isBarcodeLoading = false;
      });
    }
  }

  void _setTargetSugar() {
    final target = double.tryParse(_targetSugarController.text.trim());
    if (target != null && target > 0) {
      setState(() {
        _targetSugar = target; // Set the target sugar
        _targetSet = true; // Mark target as set
        _saveSugarData(); // Save to Firestore
      });
      _targetSugarController.clear(); // Clear the input field
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid positive number')),
      );
    }
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _barcodeController.dispose();
    _targetSugarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome Back,",
                        style: TextStyle(fontSize: 18, color: Colors.black54),
                      ),
                      Text(
                        "Stefani Wong",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.blue[100],
                    child: CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.deepOrange,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Sugar intake card
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 4),
                    ]),
                child: Column(
                  children: [
                    Text(
                      "Sugar Intake Per Day",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 140,
                          height: 140,
                          child: _targetSet // Only show progress bar if target is set
                              ? CircularProgressIndicator(
                            value: _consumedSugar / _targetSugar!,
                            strokeWidth: 12,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation(Colors.blue),
                          )
                              : Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey[200],
                            ),
                          ), // Placeholder circle when target not set
                        ),
                        Text(
                          _targetSet ? "${_targetSugar!.toStringAsFixed(0)}g" : "Set Target",
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Consumed", style: TextStyle(fontSize: 14)),
                                SizedBox(height: 4),
                                Text(
                                  _targetSet ? "${_consumedSugar.toStringAsFixed(0)}g" : "",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Left", style: TextStyle(fontSize: 14)),
                                SizedBox(height: 4),
                                Text(
                                  _targetSet ? "${(_targetSugar! - _consumedSugar).clamp(0, double.infinity).toStringAsFixed(0)}g" : "",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Log Intake Card (Product Name)
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 4),
                    ]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Log Food",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _productNameController,
                            decoration: InputDecoration(
                              hintText: "Enter Food Name",
                              hintStyle: TextStyle(color: Colors.black54),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black54),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        IconButton(
                          onPressed: _searchProductByName,
                          icon: Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        )
                      ],
                    ),
                    if (_isLoading)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (_sugarContent.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          _sugarContent,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 4),
                    ]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Log Food by Barcode",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _barcodeController,
                            decoration: InputDecoration(
                              hintText: "Enter Barcode",
                              hintStyle: TextStyle(color: Colors.black54),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black54),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        IconButton(
                          onPressed: _fetchSugarContentByBarcode,
                          icon: Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        )
                      ],
                    ),
                    if (_isBarcodeLoading)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (_barcodeSugarContent.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          _barcodeSugarContent,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 4),
                    ]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Set Target Sugar Intake",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _targetSugarController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: "Enter target sugar (g)",
                              hintStyle: TextStyle(color: Colors.black54),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black54),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        IconButton(
                          onPressed: _setTargetSugar,
                          icon: Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),

              /*SizedBox(height: 20),
              Container(
                padding: ,
              )*/

            ],
          ),
        ),
      ),
    );
  }
}