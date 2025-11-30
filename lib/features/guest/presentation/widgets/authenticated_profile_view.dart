import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:villavibe/features/auth/data/repositories/auth_repository.dart';
import 'package:villavibe/features/host/presentation/providers/host_mode_provider.dart';
import 'package:villavibe/features/host/presentation/screens/onboarding/host_onboarding_screen.dart';
import 'package:villavibe/core/utils/seed_data.dart';
import 'package:villavibe/features/properties/data/repositories/property_repository.dart';
import 'package:villavibe/features/host/presentation/screens/mode_transition_screen.dart';

class AuthenticatedProfileView extends ConsumerWidget {
  const AuthenticatedProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;

    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Profile',
                      style:
                          Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                    ),
                    IconButton(
                      onPressed: () {
                        // Notifications
                      },
                      icon: const Icon(Icons.notifications_outlined, size: 28),
                    ),
                  ],
                ),
              ),

              // User Info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.grey[800],
                      child: Text(
                        user.displayName.isNotEmpty == true
                            ? user.displayName[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.displayName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Text(
                            'Guest',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Cards Section (Past trips, Connections)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    _buildCard(
                      context,
                      title: 'Past trips',
                      icon: Icons.luggage, // Placeholder icon
                      isNew: true,
                    ),
                    const SizedBox(width: 16),
                    _buildCard(
                      context,
                      title: 'Connections',
                      icon: Icons.people_outline, // Placeholder icon
                      isNew: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Become a host banner
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: InkWell(
                  onTap: () async {
                    // Always check if user has any listings, regardless of isHost flag
                    // This handles cases where isHost might be out of sync
                    final hasProperties = await ref
                        .read(propertyRepositoryProvider)
                        .hasProperties(user.uid);
                    
                    if (hasProperties) {
                      // Trigger Premium Transition
                      if (context.mounted) {
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) =>
                                const ModeTransitionScreen(targetIsHost: true),
                            transitionsBuilder:
                                (context, animation, secondaryAnimation, child) {
                              const begin = Offset(0.0, 1.0);
                              const end = Offset.zero;
                              const curve = Curves.easeInOut;

                              var tween = Tween(begin: begin, end: end)
                                  .chain(CurveTween(curve: curve));

                              return SlideTransition(
                                position: animation.drive(tween),
                                child: child,
                              );
                            },
                            transitionDuration: const Duration(milliseconds: 500),
                            reverseTransitionDuration: const Duration(milliseconds: 500),
                          ),
                        );
                      }
                    } else {
                      // No listings yet, go to Onboarding
                      if (context.mounted) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const HostOnboardingScreen(),
                          ),
                        );
                      }
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Row(
                      children: [
                        // Placeholder image/icon
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.home_work_outlined,
                              color: Color(0xFFE31C5F)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Switch to Host Mode',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Access your dashboard and listings.',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Settings List
              _buildListTile(
                  context, Icons.settings_outlined, 'Account settings'),
              _buildListTile(context, Icons.help_outline, 'Get help'),
              _buildListTile(context, Icons.person_outline, 'View profile'),
              _buildListTile(context, Icons.handshake_outlined, 'Privacy'),
              const SizedBox(height: 24),

              _buildListTile(context, Icons.people_outline, 'Refer a host'),
              _buildListTile(
                  context, Icons.person_add_outlined, 'Find a co-host'),
              _buildListTile(context, Icons.menu_book_outlined, 'Legal'),

              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                leading:
                    const Icon(Icons.logout, color: Colors.black87, size: 28),
                title: Text(
                  'Log out',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w400,
                        color: Colors.black87,
                      ),
                ),
                onTap: () {
                  ref.read(authRepositoryProvider).signOut();
                },
              ),

              const SizedBox(height: 24),
              const Divider(height: 1),
              const SizedBox(height: 24),
              const Divider(height: 1),
              
              // Developer Options
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Developer Options',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.cloud_upload_outlined, color: Colors.blue),
                      title: const Text('Seed Firestore Data'),
                      subtitle: const Text('Uploads 5 rich-data properties'),
                      onTap: () async {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Seeding data...')),
                        );
                        try {
                          await ref
                              .read(propertyRepositoryProvider)
                              .seedProperties(seedProperties);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Data seeded successfully! Pull to refresh home.'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error seeding data: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Version 1.0.0',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context,
      {required String title, required IconData icon, bool isNew = false}) {
    return Container(
      width: 160,
      height: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: Colors.brown[400]),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          if (isNew)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C3E50),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'NEW',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildListTile(BuildContext context, IconData icon, String title) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Icon(icon, color: Colors.black87, size: 28),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w400,
              color: Colors.black87,
            ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.black54),
      onTap: () {
        // TODO: Implement navigation
      },
    );
  }
}
