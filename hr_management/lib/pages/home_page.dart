import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // Custom Color from the image (light green/mint)
  static const Color primaryLightColor = Color(0xFFE8F5E9);
  static const Color primaryDarkColor = Color(0xFF388E3C);

  @override
  Widget build(BuildContext context) {
    // Determine screen size for responsiveness (simple adaptation)
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth > 800;

    return Scaffold(
      // --- Top Navigation/App Bar ---
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isLargeScreen ? 60.0 : 0.0,
            ),
            child: Row(
              children: <Widget>[
                const Text(
                  'HRMS',
                  style: TextStyle(
                    color: primaryDarkColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                const Spacer(),
                _buildSignInButton(context),
                const SizedBox(width: 8),
                _buildSignUpButton(context),
              ],
            ),
          ),
        ),
      ),
      // --- Body Content ---
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // --- Hero Section (Green Background) ---
            Container(
              width: double.infinity,
              color: primaryLightColor,
              padding: EdgeInsets.symmetric(
                vertical: 80.0,
                horizontal: isLargeScreen ? screenWidth * 0.1 : 20.0,
              ),
              child: Column(
                children: <Widget>[
                  // Title
                  const Text(
                    'Welcome to HRMS',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: primaryDarkColor,
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tagline
                  Text(
                    'Empowering organizations with streamlined human resource solutions — connecting candidates, employees, and investors in one trusted platform.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: isLargeScreen ? 20 : 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Main Description
                  Container(
                    constraints: BoxConstraints(maxWidth: 800),
                    child: Text(
                      'At HRMS, we are dedicated to revolutionizing human resource management by providing innovative tools that enhance efficiency, transparency, and connectivity. Our platform empowers organizations to build stronger teams and fosters growth for candidates, employees, and investors alike.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: isLargeScreen ? 16 : 14,
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // "Join Us" Button
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to the registration page
                      Navigator.of(context).pushNamed('/registration');
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: primaryDarkColor,
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        side: const BorderSide(color: primaryDarkColor),
                      ),
                      elevation: 0,
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Text('Join Us'),
                  ),
                ],
              ),
            ),

            // --- Footer/Security Section (White Background) ---
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 40.0,
                horizontal: 20.0,
              ),
              child: Wrap(
                spacing: 20.0,
                runSpacing: 20.0,
                alignment: WrapAlignment.center,
                children: <Widget>[
                  _buildSecurityCard(
                    context,
                    icon: Icons.lock_outline,
                    text: 'Secure & Confidential',
                  ),
                  _buildSecurityCard(
                    context,
                    icon: Icons.shield_outlined,
                    text: 'GDPR Compliant',
                  ),
                  _buildSecurityCard(
                    context,
                    icon: Icons.thumb_up_alt_outlined,
                    text: 'Trusted by 1000+ organizations',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build the "Sign In" button
  Widget _buildSignInButton(BuildContext context) {
    return OutlinedButton(
      onPressed: () {
        Navigator.of(context).pushNamed('/login');
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryDarkColor,
        side: const BorderSide(color: primaryDarkColor, width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.0)),
      ),
      child: const Text(
        'Sign In',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  // Helper method to build the "Sign Up" button
  Widget _buildSignUpButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.of(context).pushNamed('/registration');
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: primaryDarkColor,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.0)),
      ),
      child: const Text(
        'Sign Up',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  // Helper method to build the security/compliance cards
  Widget _buildSecurityCard(
    BuildContext context, {
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, color: Colors.orange, size: 20),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method for the mobile drawer
  Widget _buildMobileDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(color: primaryLightColor),
            child: const Text(
              'HRMS Navigation',
              style: TextStyle(
                color: primaryDarkColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildDrawerItem(context, 'Home', Icons.home, '/home'),
          _buildDrawerItem(context, 'About', Icons.info_outline, '/'),
          _buildDrawerItem(
            context,
            'Services',
            Icons.business_center_outlined,
            '/',
          ),
          _buildDrawerItem(
            context,
            'Contact',
            Icons.contact_mail_outlined,
            '/',
          ),
        ],
      ),
    );
  }

  // Helper method for drawer list tiles
  Widget _buildDrawerItem(
    BuildContext context,
    String title,
    IconData icon,
    String route,
  ) {
    return ListTile(
      leading: Icon(icon, color: primaryDarkColor),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        if (route.isNotEmpty && route != '/') {
          Navigator.of(context).pushNamed(route);
        }
      },
    );
  }
}
