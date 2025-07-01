import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'create_post_page.dart';
import 'comment_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeFeedPage(),
    const ExplorePage(),
    const AddPostPage(),
    const NotificationsPage(),
    const MyPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined, size: 30),
            activeIcon: Icon(Icons.home, size: 30, color: Colors.black),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined, size: 30),
            activeIcon: Icon(Icons.explore, size: 30, color: Colors.black),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined, size: 30),
            activeIcon: Icon(Icons.add_box, size: 30, color: Colors.black),
            label: 'Add Post',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none_outlined, size: 30),
            activeIcon: Icon(Icons.notifications, size: 30, color: Colors.black),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline, size: 30),
            activeIcon: Icon(Icons.person, size: 30, color: Colors.black),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// Placeholder pages for each tab
class HomeFeedPage extends StatefulWidget {
  const HomeFeedPage({super.key});

  @override
  State<HomeFeedPage> createState() => _HomeFeedPageState();
}

class _HomeFeedPageState extends State<HomeFeedPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _selectedCategory; // null means 'All Categories'

  // Show comments in a bottom sheet
  void _showComments(BuildContext context, String postId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, controller) => CommentSection(postId: postId),
      ),
    );
  }

  // Toggle like on a post
  // Build a category filter chip
  Widget _buildCategoryChip(String label, String? category) {
    final isSelected = _selectedCategory == category;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _selectedCategory = isSelected ? null : category;
        });
      },
      backgroundColor: Colors.grey[200],
      selectedColor: Colors.blue[100],
      labelStyle: TextStyle(
        color: isSelected ? Colors.blue[900] : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? Colors.blue : Colors.grey[300]!,
          width: 1,
        ),
      ),
    );
  }

  Future<void> _toggleLike(String postId, List<dynamic> likedBy) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;
      
      final isLiked = likedBy.contains(userId);
      
      await _firestore.collection('posts').doc(postId).update({
        'likedBy': isLiked 
            ? FieldValue.arrayRemove([userId])
            : FieldValue.arrayUnion([userId]),
        'likeCount': isLiked 
            ? FieldValue.increment(-1)
            : FieldValue.increment(1),
      });
    } catch (e) {
      debugPrint('Error toggling like: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update like')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('posts')
            .orderBy('createdAt', descending: true)
            .snapshots(includeMetadataChanges: true),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No posts yet'));
          }

          // Filter posts by selected category if any
          final filteredDocs = _selectedCategory == null
              ? snapshot.data!.docs
              : snapshot.data!.docs.where((doc) => 
                  (doc.data() as Map<String, dynamic>)['category'] == _selectedCategory).toList();

          return Column(
            children: [
              // Category Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    _buildCategoryChip('All', null),
                    const SizedBox(width: 8),
                    _buildCategoryChip('Work', 'Work'),
                    const SizedBox(width: 8),
                    _buildCategoryChip('Health', 'Health'),
                    const SizedBox(width: 8),
                    _buildCategoryChip('Relationships', 'Relationships'),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Posts List or Empty State
              if (filteredDocs.isEmpty)
                const Expanded(
                  child: Center(
                    child: Text('No posts found for the selected category'),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final post = filteredDocs[index];
                    final data = post.data() as Map<String, dynamic>;
                    final timestamp = data['createdAt'] as Timestamp?;
                    final dateTime = timestamp?.toDate();
                    final likedBy = List<dynamic>.from(data['likedBy'] ?? []);
                    final isLiked = _auth.currentUser != null &&
                        likedBy.contains(_auth.currentUser!.uid);

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.blue[100],
                                  child: Text(
                                    (data['author']?[0] ?? 'U').toUpperCase(),
                                    style: const TextStyle(color: Colors.blue),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['isAnonymous'] == true ? 'Anonymous' : (data['username'] ?? 'User'),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (dateTime != null)
                                      Text(
                                        _formatDateTime(dateTime),
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Post title
                            if (data['title'] != null && data['title'].toString().isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Text(
                                  data['title'],
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            // Post content
                            Text(
                              data['content'] ?? '',
                              style: const TextStyle(fontSize: 16, height: 1.4),
                            ),
                            const SizedBox(height: 12),
                            // Like and comment counters
                            Row(
                              children: [
                                // Like button
                                IconButton(
                                  icon: Icon(
                                    isLiked ? Icons.favorite : Icons.favorite_border,
                                    color: isLiked ? Colors.red : Colors.grey[600],
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    if (_auth.currentUser != null) {
                                      _toggleLike(post.id, likedBy);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Please sign in to like posts'),
                                        ),
                                      );
                                    }
                                  },
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                                const SizedBox(width: 8),
                                Text('${data['likeCount'] ?? 0}'),
                                const SizedBox(width: 24),
                                // Comment button
                                IconButton(
                                  icon: const Icon(Icons.comment_outlined, size: 20),
                                  onPressed: () => _showComments(context, post.id),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                                const SizedBox(width: 8),
                                Text('${data['commentCount'] ?? 0}'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreatePostPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    
    return '${dateTime.year}/${dateTime.month}/${dateTime.day}';
  }
}

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Explore', style: TextStyle(fontSize: 24)));
  }
}

class AddPostPage extends StatelessWidget {
  const AddPostPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    // This will navigate to CreatePostPage when the tab is selected
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CreatePostPage()),
      );
    });
    
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Notifications', style: TextStyle(fontSize: 24)));
  }
}

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    
    return '${dateTime.year}/${dateTime.month}/${dateTime.day}';
  }
  
  String _getUsernameFromEmail() {
    final user = _auth.currentUser;
    if (user?.email != null) {
      return user!.email!.split('@').first;
    }
    return 'User';
  }
  
  Future<void> _deletePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete post')),
        );
      }
    }
  }
  
  Future<void> _editPost(String postId, String currentTitle, String currentContent) async {
    final TextEditingController titleController = TextEditingController(text: currentTitle);
    final TextEditingController contentController = TextEditingController(text: currentContent);
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Post'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                maxLines: 1,
                maxLength: 100,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 8,
                minLines: 5,
                maxLength: 2000,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              if (titleController.text.trim().isNotEmpty && contentController.text.trim().isNotEmpty) {
                Navigator.pop(context, true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill in all fields')),
                );
              }
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
    
    if (result == true) {
      try {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );

        // Update the post
        await _firestore.collection('posts').doc(postId).update({
          'title': titleController.text.trim(),
          'content': contentController.text.trim(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        
        // Close loading indicator
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post updated successfully')),
          );
        }
      } catch (e) {
        // Close loading indicator if there's an error
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update post: ${e.toString()}')),
          );
        }
        debugPrint('Error updating post: $e');
      }
    }
  }

  void _showComments(BuildContext context, String postId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, controller) => CommentSection(postId: postId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) {
      return const Center(child: Text('Please sign in to view your posts'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('MY SPACE'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _auth.signOut(),
          ),
        ],
      ),
      body: user == null
          ? const Center(child: Text('Please sign in to view your profile'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Info Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.blue[100],
                            child: Text(
                              _getUsernameFromEmail().isNotEmpty ? _getUsernameFromEmail()[0].toUpperCase() : 'U',
                              style: const TextStyle(fontSize: 36, color: Colors.blue),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getUsernameFromEmail(),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user.email ?? 'No email',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  const Text(
                    'Your Posts',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  
                  // User's Posts
                  StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('posts')
                        .where('userId', isEqualTo: user.uid)
                        .orderBy('createdAt', descending: true)
                        .snapshots(
                          includeMetadataChanges: true,  // This will help with debugging
                        ),
                    builder: (context, snapshot) {
                      // Debug log the current user's UID and query details
                      debugPrint('Current user UID: ${user.uid}');
                      debugPrint('Query: where userId == ${user.uid}');
                      debugPrint('Has data: ${snapshot.hasData}');
                      debugPrint('Has error: ${snapshot.error}');
                      debugPrint('Connection state: ${snapshot.connectionState}');
                      debugPrint('Document count: ${snapshot.data?.docs.length}');
                      // Debug logging
                      if (snapshot.hasError) {
                        debugPrint('Error fetching posts: ${snapshot.error}');
                      }
                      if (snapshot.connectionState == ConnectionState.active) {
                        debugPrint('Number of posts found: ${snapshot.data?.docs.length ?? 0}');
                        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                          debugPrint('First post data: ${snapshot.data!.docs.first.data()}');
                        }
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('You have not created any posts yet.'),
                          ),
                        );
                      }
                      
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          final post = snapshot.data!.docs[index];
                          final data = post.data() as Map<String, dynamic>;
                          final timestamp = data['createdAt'] as Timestamp?;
                          final dateTime = timestamp?.toDate();
                          // No need for these variables as they're not used in this scope
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            _formatDateTime(dateTime),
                                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                          ),
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.edit, size: 20),
                                                onPressed: () => _editPost(
                                                  post.id,
                                                  data['title'] ?? '',
                                                  data['content'] ?? '',
                                                ),
                                                padding: EdgeInsets.zero,
                                                constraints: const BoxConstraints(),
                                                visualDensity: VisualDensity.compact,
                                              ),
                                              const SizedBox(width: 4),
                                              IconButton(
                                                icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                                onPressed: () => showDialog(
                                                  context: context,
                                                  builder: (context) => AlertDialog(
                                                    title: const Text('Delete Post'),
                                                    content: const Text('Are you sure you want to delete this post?'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () => Navigator.pop(context),
                                                        child: const Text('CANCEL'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          _deletePost(post.id);
                                                          Navigator.pop(context);
                                                        },
                                                        style: TextButton.styleFrom(
                                                          foregroundColor: Colors.red,
                                                        ),
                                                        child: const Text('DELETE'),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                padding: EdgeInsets.zero,
                                                constraints: const BoxConstraints(),
                                                visualDensity: VisualDensity.compact,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        data['title'] ?? 'No title',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(data['content'] ?? ''),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Icon(Icons.favorite, size: 18, color: Colors.grey[600]),
                                          const SizedBox(width: 8),
                                          Text('${data['likeCount'] ?? 0}'),
                                          const SizedBox(width: 16),
                                          // Comment button
                                          IconButton(
                                            icon: const Icon(Icons.comment_outlined, size: 20),
                                            onPressed: () => _showComments(context, post.id),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                          ),
                                          const SizedBox(width: 8),
                                          Text('${data['commentCount'] ?? 0}'),
                                          const SizedBox(width: 16),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
