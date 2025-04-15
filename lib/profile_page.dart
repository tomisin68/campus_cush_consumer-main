import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isVerifiedAgent = false; // Change this to test verified/non-verified UI
  int postCount = 12;
  int earnings = 2450;
  int profileViews = 1243;
  int messagesReceived = 56;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    const primaryColor = Color(0xFF0A0E21);
    final cardColor = isDarkMode ? Colors.grey[900] : Colors.grey[100];
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[850] : Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: primaryColor,
              statusBarIconBrightness: Brightness.light,
            ),
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: primaryColor,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // User Header Section
                  _buildUserHeader(isVerifiedAgent, textColor, cardColor!),
                  const SizedBox(height: 30),

                  // Quick Stats (for verified agents)
                  if (isVerifiedAgent)
                    _buildAgentStats(primaryColor, textColor),

                  // Quick Actions Grid
                  _buildQuickActionsGrid(
                      primaryColor, textColor, isVerifiedAgent),
                  const SizedBox(height: 20),

                  // Settings Section
                  _buildSettingsSection(cardColor, textColor),
                  const SizedBox(height: 20),

                  // Support Section
                  _buildSupportSection(cardColor, textColor),
                  const SizedBox(height: 20),

                  // Legal Section
                  _buildLegalSection(cardColor, textColor),
                  const SizedBox(height: 20),

                  // Logout & App Info
                  _buildLogoutSection(textColor),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserHeader(bool isVerified, Color textColor, Color cardColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Profile Picture
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 2,
              )
            ],
            image: const DecorationImage(
              image: NetworkImage(
                  'https://randomuser.me/api/portraits/women/44.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Samuel Oluwabiyi',
                style: GoogleFonts.roboto(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isVerified ? Colors.green[100] : Colors.blue[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isVerified ? '✅ Verified Agent' : 'Student',
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isVerified ? Colors.green[800] : Colors.blue[800],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.school, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'University of California',
                    style: GoogleFonts.roboto(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Column(
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.grey[600]),
              onPressed: () {
                // Edit profile action
              },
            ),
            const SizedBox(height: 8),
            IconButton(
              icon: Icon(Icons.qr_code, color: Colors.grey[600]),
              onPressed: () {
                // Share profile action
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAgentStats(Color primaryColor, Color textColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem('Posts', postCount.toString(), Icons.list_alt),
              _buildStatItem('Earnings', '\$$earnings', Icons.attach_money),
              _buildStatItem(
                  'Views', profileViews.toString(), Icons.remove_red_eye),
              _buildStatItem(
                  'Messages', messagesReceived.toString(), Icons.message),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: 0.7,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            minHeight: 6,
          ),
          const SizedBox(height: 6),
          Text(
            'Profile completeness: 70%',
            style: GoogleFonts.roboto(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF0A0E21)),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.roboto(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsGrid(
      Color primaryColor, Color textColor, bool isVerified) {
    final actions = [
      {
        'title': isVerified ? 'Post Accommodation' : 'Become Verified Agent',
        'icon': isVerified ? Icons.home_work : Icons.verified_user,
        'color': isVerified ? Colors.green : Colors.blue,
        'disabled': false
      },
      {
        'title': 'Chats',
        'icon': Icons.chat_bubble,
        'color': Colors.purple,
        'disabled': false
      },
      {
        'title': 'Find Roommate',
        'icon': Icons.people,
        'color': Colors.orange,
        'disabled': false
      },
      {
        'title': 'Referrals & Credits',
        'icon': Icons.card_giftcard,
        'color': Colors.red,
        'disabled': false
      },
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: actions.map((action) {
        return GestureDetector(
          onTap: () {
            if (action['title'] == 'Become Verified Agent') {
              _showVerificationBottomSheet();
            } else if (!(action['disabled'] as bool)) {
              // Handle other actions
              _showComingSoonSnackbar(action['title'] as String);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  (action['color'] as Color).withOpacity(0.2),
                  (action['color'] as Color).withOpacity(0.05),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
              border: Border.all(
                color: (action['color'] as Color).withOpacity(0.3),
                width: 0.5,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {}, // Handled by parent GestureDetector
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        action['icon'] as IconData,
                        size: 30,
                        color: action['color'] as Color,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        action['title'] as String,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSettingsSection(Color cardColor, Color textColor) {
    final settingsItems = [
      {'title': 'Personal Information', 'icon': Icons.person_outline},
      {'title': 'Login & Security', 'icon': Icons.lock_outline},
      {'title': 'Payments & Payouts', 'icon': Icons.payment},
      {'title': 'Notifications', 'icon': Icons.notifications_outlined},
      {'title': 'Appearance', 'icon': Icons.color_lens_outlined},
      {'title': 'Language', 'icon': Icons.language},
    ];

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: List.generate(settingsItems.length, (index) {
          final item = settingsItems[index];
          return Column(
            children: [
              ListTile(
                leading:
                    Icon(item['icon'] as IconData, color: Colors.grey[600]),
                title: Text(
                  item['title'] as String,
                  style: GoogleFonts.roboto(
                    fontSize: 15,
                    color: textColor,
                  ),
                ),
                trailing: Icon(Icons.chevron_right, color: Colors.grey[500]),
                onTap: () {
                  _showComingSoonSnackbar(item['title'] as String);
                },
              ),
              if (index != settingsItems.length - 1)
                Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: Colors.grey.withOpacity(0.1),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSupportSection(Color cardColor, Color textColor) {
    final supportItems = [
      {'title': 'Contact Help Center', 'icon': Icons.help_outline},
      {'title': 'Report a Problem', 'icon': Icons.flag_outlined},
      {'title': 'How the App Works', 'icon': Icons.info_outline},
      {'title': 'Give Feedback', 'icon': Icons.feedback_outlined},
    ];

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 16),
            child: Text(
              'Support',
              style: GoogleFonts.roboto(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
          Column(
            children: List.generate(supportItems.length, (index) {
              final item = supportItems[index];
              return Column(
                children: [
                  ListTile(
                    leading:
                        Icon(item['icon'] as IconData, color: Colors.grey[600]),
                    title: Text(
                      item['title'] as String,
                      style: GoogleFonts.roboto(
                        fontSize: 15,
                        color: textColor,
                      ),
                    ),
                    trailing:
                        Icon(Icons.chevron_right, color: Colors.grey[500]),
                    onTap: () {
                      if (item['title'] == 'Give Feedback') {
                        _showFeedbackBottomSheet();
                      } else {
                        _showComingSoonSnackbar(item['title'] as String);
                      }
                    },
                  ),
                  if (index != supportItems.length - 1)
                    Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                      color: Colors.grey.withOpacity(0.1),
                    ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalSection(Color cardColor, Color textColor) {
    final legalItems = [
      {'title': 'Terms of Use', 'icon': Icons.description_outlined},
      {'title': 'Privacy Policy', 'icon': Icons.lock_outline},
    ];

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: List.generate(legalItems.length, (index) {
          final item = legalItems[index];
          return Column(
            children: [
              ListTile(
                leading:
                    Icon(item['icon'] as IconData, color: Colors.grey[600]),
                title: Text(
                  item['title'] as String,
                  style: GoogleFonts.roboto(
                    fontSize: 15,
                    color: textColor,
                  ),
                ),
                trailing: Icon(Icons.chevron_right, color: Colors.grey[500]),
                onTap: () {
                  _showComingSoonSnackbar(item['title'] as String);
                },
              ),
              if (index != legalItems.length - 1)
                Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: Colors.grey.withOpacity(0.1),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildLogoutSection(Color textColor) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: Colors.grey.withOpacity(0.3)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              // Logout action
            },
            child: Text(
              'Log Out',
              style: GoogleFonts.roboto(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Campus Cush v1.0.0',
          style: GoogleFonts.roboto(
            fontSize: 12,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  void _showVerificationBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Become a Verified Agent',
                style: GoogleFonts.roboto(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'You must be a verified agent to post accommodation listings.',
                style: GoogleFonts.roboto(
                  fontSize: 15,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 20),
              _buildBenefitItem(
                  Icons.verified, 'Verified badge on your profile'),
              _buildBenefitItem(Icons.home, 'Post unlimited accommodations'),
              _buildBenefitItem(Icons.attach_money, 'Earn money from rentals'),
              _buildBenefitItem(
                  Icons.star, 'Higher visibility in search results'),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A0E21),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    // Open verification webview
                  },
                  child: Text(
                    'Start Verification',
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Not now',
                  style: GoogleFonts.roboto(
                    fontSize: 15,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBenefitItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.green),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.roboto(
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFeedbackBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Give Feedback',
                style: GoogleFonts.roboto(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'We\'d love to hear your thoughts about the app!',
                style: GoogleFonts.roboto(
                  fontSize: 15,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'How would you rate your experience?',
                style: GoogleFonts.roboto(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                        index < 4
                            ? Icons.sentiment_very_satisfied
                            : Icons.sentiment_neutral,
                        size: 40,
                        color: index < 4 ? Colors.amber : Colors.grey),
                    onPressed: () {},
                  );
                }),
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Your feedback (optional)',
                  labelStyle: GoogleFonts.roboto(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A0E21),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Thank you for your feedback!',
                          style: GoogleFonts.roboto(),
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  child: Text(
                    'Submit Feedback',
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.roboto(
                    fontSize: 15,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showComingSoonSnackbar(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$feature coming soon!',
          style: GoogleFonts.roboto(),
        ),
        backgroundColor: const Color(0xFF0A0E21),
      ),
    );
  }
}
