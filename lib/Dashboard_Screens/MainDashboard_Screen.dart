import 'package:flutter/material.dart';
import 'package:g21285889_daniru_gihen/Dashboard_Screens/Insights_Screen.dart';
import 'package:g21285889_daniru_gihen/Dashboard_Screens/Profile_Screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


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
  String _sugarContent = '';
  String _barcodeSugarContent = '';
  bool _isLoading = false;
  bool _isBarcodeLoading = false;
  double? _targetSugar; // Starts as null until user sets it
  double _consumedSugar = 0.0; // Starts at 0
  bool _targetSet = false; // Tracks if target has been set
  Map<String, double> _dailySugar = {};
  //Map<String, double> _WeeklySugar = {};
  List<Map<String,dynamic>> _searchResults = [];
  String _firstName = 'User';
  String _lastName = '';

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
        final todayDate = DateTime.now().toIso8601String().split('T')[0];

        setState(() {
          _targetSugar = data['targetSugar']?.toDouble();
          _targetSet = _targetSugar != null; // Target is set if it exists in Firestore
          _dailySugar = Map<String, double>.from(data['dailySugar'] ?? {});
          _firstName = data['firstName'] ?? 'User';
          _lastName = data['lastName'] ?? '';

          // Check if there's data for today; if not, reset _consumedSugar to 0
          if (_dailySugar.containsKey(todayDate)) {
            _consumedSugar = _dailySugar[todayDate] ?? 0.0;
          } else {
            _consumedSugar = 0.0; // Reset to 0 for a new day
            _dailySugar[todayDate] = 0.0; // Initialize today's entry
            _saveSugarData(); // Save the reset value to Firestore
          }
        });
      }
    }
  }

  // Save product log to Firestore
  Future<void> _saveProductLog(String productName, double sugarAmount) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final todayDate = DateTime.now().toIso8601String().split('T')[0]; // sort the date in this format "2025-03-27"
      final logRef = FirebaseFirestore.instance
          .collection('product_logs')
          .doc(user.uid)
          .collection('logs')
          .doc(); // Auto-generate a document ID for each log entry

      await logRef.set({
        'productName': productName,
        'sugarAmount': sugarAmount,
        'date': todayDate,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

// Fetch product data from API
  Future<Map<String, dynamic>?> _fetchProductData(Uri url, String errorMessagePrefix) async {
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        setState(() {
          _barcodeSugarContent = '$errorMessagePrefix (Status: ${response.statusCode})';
        });
        return null;
      }
    } catch (e) {
      setState(() {
        _barcodeSugarContent = 'Error: $e';
      });
      return null;
    }
  }

  // Save sugar data to Firestore
  Future<void> _saveSugarData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final todayDate = DateTime.now().toIso8601String().split('T')[0]; // e.g., "2025-03-26"
      _dailySugar[todayDate] = _consumedSugar; // Update today's sugar
      await docRef.set({
        'targetSugar': _targetSugar,
        'consumedSugar': _consumedSugar,
        'dailySugar': _dailySugar, // Save the daily sugar map
      }, SetOptions(merge: true)); // Merge to avoid overwriting other fields
    }
  }

  //Search product by name using OpenFoodFacts API using endpoints
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
      _searchResults = [];
    });
    try {
      final encodedName = Uri.encodeComponent(productName);
      final url = Uri.parse('https://world.openfoodfacts.net/cgi/search.pl?search_terms=$encodedName&search_simple=1&json=1');

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['products'] != null && data['products'].length > 0) {
         setState(() {
           _searchResults = List<Map<String, dynamic>>.from(data['products']);
         });
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

// Log selected product and update sugar consumption
  void _logProduct(Map<String, dynamic> product){
    if (product['nutriments'] != null && product['nutriments']['sugars_100g'] != null) {
      final sugar = product['nutriments']['sugars_100g'].toDouble();
      final productNameFound = product['product_name'] ?? 'Unknown Product';
      setState(() {
        _sugarContent = 'Sugar Content for $productNameFound: $sugar g per 100g';
        if (_targetSet) {
          _consumedSugar += sugar; // Add sugar (assuming 100g serving)
          _saveSugarData(); // Save to Firestore
        }
        _saveProductLog(productNameFound, sugar);
        _searchResults = []; // Clear search results after selection
        _productNameController.clear(); // Clear the search bar
      });
    } else {
      setState(() {
        _sugarContent = 'Sugar content not found for this product';
        _searchResults = []; // Clear search results
        _productNameController.clear(); // Clear the search bar
      });
    }
  }

  // Fetch sugar content by barcode using Open Food Facts API
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

    final url = Uri.parse('https://world.openfoodfacts.org/api/v2/product/$barcode.json');
    final data = await _fetchProductData(url, 'Error: Failed to fetch product data');

    if (data != null) {
      if (data['status'] == 1 && data['product'] != null) {
        final product = data['product'];
        if (product['nutriments'] != null && product['nutriments'].containsKey('sugars_100g')) {
          _logProduct(product); // Reuse _logProduct to log the sugar content
          setState(() {
            _barcodeSugarContent = _sugarContent; // Use the same message format
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
    }

    setState(() {
      _isBarcodeLoading = false;
    });
  }

  // Clean up controllers
  @override
  void dispose() {
    _productNameController.dispose();
    _barcodeController.dispose();
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
                        "$_firstName $_lastName",
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
                            value: (_consumedSugar / _targetSugar!).clamp(0.0, 1.0),
                            strokeWidth: 12,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation(
                              _consumedSugar > _targetSugar! ? Colors.red : Colors.blue,
                            ),
                          )
                              : Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey[200],
                            ),
                          ), // Placeholder circle when target not set
                        ),
                        Text(
                            _targetSet ? "${_consumedSugar.toStringAsFixed(0)}g" : "Set Target",
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)
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
                                Text(
                                  _targetSet && _consumedSugar > _targetSugar!
                                      ?"Over"
                                      :"Left",
                                  style: TextStyle(fontSize: 14),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  _targetSet
                                      ? _consumedSugar > _targetSugar!
                                      ?"${(_consumedSugar - _targetSugar!).toStringAsFixed(0)}g"
                                      :"${(_targetSugar! - _consumedSugar).clamp(0, double.infinity).toStringAsFixed(0)}g"
                                      : "",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: _targetSet && _consumedSugar >_targetSugar!
                                        ? Colors.red
                                        :Colors.black,
                                  ),
                                )
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
                              Icons.search,
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
                    else if (_searchResults.isNotEmpty)
                      Container(
                        constraints: BoxConstraints(maxHeight: 200),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index){
                            final product = _searchResults[index];
                            final productName = product['product_name']??'Unknown Product';
                            return ListTile(
                              title: Text(
                                productName,
                                style: TextStyle(fontSize: 16),
                              ),
                              onTap: () => _logProduct(product),
                            );
                          },
                        ),
                      )
                    else if(_sugarContent.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 16.0),
                        child: Text(
                          _sugarContent,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
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
            ],
          ),
        ),
      ),
    );
  }
}

