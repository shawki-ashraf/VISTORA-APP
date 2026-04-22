import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mira_fashon/features/auth/login_view/cubit/account_cubit.dart';
import 'package:mira_fashon/features/auth/login_view/view/login_view.dart';
import 'package:mira_fashon/features/profile/cubit/profile_cubit.dart';
import 'package:mira_fashon/features/profile/data/profiledata_model.dart';

class FashionProfileScreen extends StatelessWidget {
  const FashionProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff7f7f7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("My Profile", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProfileError) {
            return Center(child: Text(state.message));
          }

          if (state is ProfileLoaded) {
            final user = state.userProfile;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SizedBox(height: 20),

                /// 👤 AVATAR
                Center(
                  child: CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: user.imageUrl.isNotEmpty
                        ? NetworkImage(user.imageUrl)
                        : null,
                    child: user.imageUrl.isEmpty
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),
                ),

                const SizedBox(height: 15),

                /// USERNAME
                Center(
                  child: Text(
                    user.username,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 5),

                /// EMAIL
                Center(
                  child: Text(
                    user.email,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),

                const SizedBox(height: 15),

                /// ✏️ EDIT BUTTON (IMPORTANT FIX HERE)
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final cubit = context.read<ProfileCubit>();
                      _showEditProfileSheet(context, user, cubit);
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text("Edit Profile"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                _menuItem(Icons.shopping_bag, "My Orders", () {}),
                _menuItem(Icons.favorite, "Wishlist", () {}),
                _menuItem(Icons.settings, "Settings", () {}),

                const SizedBox(height: 30),

                /// LOGOUT
                BlocConsumer<AccountCubit, AccountState>(
                  listener: (context, state) {
                    if (state is AccountLoggedOut) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            "Logged out successfully 👋",
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );

                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginView()),
                        (route) => false,
                      );
                    }

                    if (state is AccountFailure) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(state.error)));
                    }
                  },
                  builder: (context, state) {
                    return Center(
                      child: TextButton.icon(
                        onPressed: () {
                          print("LOGOUT CLICKED");
                          context.read<AccountCubit>().logout();
                        },
                        icon: const Icon(Icons.logout, color: Colors.red),
                        label: const Text(
                          "Logout",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _menuItem(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  // ================= EDIT PROFILE SHEET (FIXED) =================

  void _showEditProfileSheet(
    BuildContext context,
    UserprofileModel user,
    ProfileCubit cubit,
  ) {
    final TextEditingController nameController = TextEditingController(
      text: user.username,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Edit Profile",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              /// USERNAME EDIT
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Username",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              /// SAVE BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    print("SAVE CLICKED 🔥");

                    await cubit.updateProfile(
                      username: nameController.text,
                      imageUrl: user.imageUrl,
                    );

                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                  ),
                  child: const Text("Save"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
