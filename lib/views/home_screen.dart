import 'package:dtx/utils/sse_connection_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/verification_request_model.dart';
import '../providers/verification_provider.dart';
import 'verification_detail_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    
    // Fetch verifications on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(verificationProvider.notifier).fetchVerifications();
      
      // Connect to SSE for real-time updates
      ref.read(sseConnectionProvider).connect();
    });
  }
  
  @override
  void dispose() {
    // Clean up SSE connection
    ref.read(sseConnectionProvider).dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(verificationProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification Requests'),
        backgroundColor: const Color(0xFF8B5CF6),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(verificationProvider.notifier).fetchVerifications();
            },
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          // Check state type by string comparison as a workaround
          final stateString = state.toString();
          
          if (stateString.startsWith('VerificationState.initial')) {
            return const Center(child: Text('Loading verifications...'));
          } 
          
          if (stateString.startsWith('VerificationState.loading')) {
            return const Center(child: CircularProgressIndicator());
          } 
          
          if (stateString.startsWith('VerificationState.error')) {
            // Extract error message from toString() format
            final errorMessage = stateString.contains('message:') 
                ? stateString.split('message:')[1].trim().replaceAll(')', '') 
                : 'Unknown error';
                
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: $errorMessage', 
                    style: const TextStyle(color: Colors.red)
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(verificationProvider.notifier).fetchVerifications();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          
          if (stateString.startsWith('VerificationState.loaded')) {
            // Create a helper method to extract requests from loaded state
            final requests = _getRequestsFromState(state);
            return _buildVerificationList(requests);
          }
          
          return const Center(child: Text('Unknown state'));
        },
      ),
    );
  }
  
  // Helper method to extract requests from the state
  List<VerificationRequest> _getRequestsFromState(dynamic state) {
    // Access the requests field dynamically if possible
    try {
      // This uses reflection-like approach which is safer than direct casting
      final stateMap = state.toString().split('(')[1].split(')')[0];
      if (stateMap.contains('requests:') && state.runtimeType.toString().contains('_Loaded')) {
        // Try to access the field using the generated class structure
        final requestsField = state.requests;
        if (requestsField is List<VerificationRequest>) {
          return requestsField;
        }
      }
    } catch (e) {
      print('Error extracting requests: $e');
    }
    
    // Fallback to empty list if we can't extract the requests
    return [];
  }
  
  Widget _buildVerificationList(List<VerificationRequest> requests) {
    if (requests.isEmpty) {
      return const Center(
        child: Text(
          'No pending verification requests',
          style: TextStyle(fontSize: 18),
        ),
      );
    }
    
    return ListView.builder(
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        return _buildVerificationListItem(request);
      },
    );
  }
  
  Widget _buildVerificationListItem(VerificationRequest request) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          // Navigate to detail view
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VerificationDetailScreen(request: request),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Profile Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: request.profileImageUrl.isNotEmpty
                    ? Image.network(
                        request.profileImageUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => 
                            _buildErrorImage(60),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return _buildLoadingImage(60);
                        },
                      )
                    : _buildErrorImage(60),
              ),
              const SizedBox(width: 16),
              // User info and verification image thumbnail
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'User ID: ${request.userId}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              // Quick action buttons
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.check_circle, color: Colors.green),
                    onPressed: () => _showApproveConfirmation(request),
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    onPressed: () => _showRejectConfirmation(request),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildErrorImage(double size) {
    return Container(
      width: size,
      height: size,
      color: Colors.grey[300],
      child: const Icon(Icons.broken_image, color: Colors.grey),
    );
  }

  Widget _buildLoadingImage(double size) {
    return Container(
      width: size,
      height: size,
      color: Colors.grey[200],
      child: const Center(
        child: SizedBox(
          width: 20, 
          height: 20, 
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
  
  void _showApproveConfirmation(VerificationRequest request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Verification'),
        content: Text('Are you sure you want to approve ${request.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _approveVerification(request.userId);
            },
            child: const Text('APPROVE'),
          ),
        ],
      ),
    );
  }
  
  void _showRejectConfirmation(VerificationRequest request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Verification'),
        content: Text('Are you sure you want to reject ${request.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _rejectVerification(request.userId);
            },
            child: const Text('REJECT', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  
  Future<void> _approveVerification(int userId) async {
    final success = await ref.read(verificationProvider.notifier).updateVerificationStatus(userId, true);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Verification approved' : 'Failed to approve verification'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }
  
  Future<void> _rejectVerification(int userId) async {
    final success = await ref.read(verificationProvider.notifier).updateVerificationStatus(userId, false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Verification rejected' : 'Failed to reject verification'),
          backgroundColor: success ? Colors.orange : Colors.red,
        ),
      );
    }
  }
}
