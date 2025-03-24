import 'package:flutter/material.dart';
import 'package:g21285889_daniru_gihen/Dashboard_Screens/Insights_Screen.dart';
import 'package:g21285889_daniru_gihen/Dashboard_Screens/Profile_Screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Dashboard_Screen extends StatefulWidget {
  const Dashboard_Screen({super.key});

  @override
  _Dashboard_ScreenState createState() => _Dashboard_ScreenState();
}

class _Dashboard_ScreenState extends State<Dashboard_Screen> {
  int _selectedIndex = 0;
  String _sugarContent = "";
  final TextEditingController _foodController = TextEditingController();
  bool _isLoading = false;

  final List<Widget> _screens = [
    HomeScreen(), // Main Dashboard
    InsightsScreen(), // Insights Screen
    ProfileScreen(), //  Profile screen
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update selected index
    });
  }

  @override
  void dispose() {
    _foodController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFCCF4E6),
      body: _screens[_selectedIndex], // Switches between screens
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
  String _sugarContent = '';
  bool _isLoading = false;

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
      // Using the search endpoint with the product name
      final encodedName = Uri.encodeComponent(productName);
      final url = Uri.parse('https://world.openfoodfacts.org/cgi/search.pl?search_terms=$encodedName&search_simple=1&action=process&json=1');

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Print the raw response to debug (optional, can remove after testing)
        print('API Response: $data');

        // Check if we have any products in the response
        if (data['products'] != null && data['products'].length > 0) {
          // Get the first product (most relevant match)
          final product = data['products'][0];

          // Check if nutriments data exists
          if (product['nutriments'] != null && product['nutriments']['sugars_100g'] != null) {
            final sugar = product['nutriments']['sugars_100g'];
            final productNameFound = product['product_name'] ?? productName;
            setState(() {
              _sugarContent = 'Sugar Content for $productNameFound: $sugar g per 100g';
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

  @override
  void dispose() {
    _productNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                        child: CircularProgressIndicator(
                          value: 123 / 150,
                          strokeWidth: 12,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation(Colors.blue),
                        ),
                      ),
                      Text(
                        "150g",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      )
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
                                "123g",
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
                                "27g",
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

            // Log Intake Card
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
          ],
        ),
      ),
    );
  }
}