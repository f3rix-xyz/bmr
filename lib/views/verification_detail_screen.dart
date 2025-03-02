
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/verification_request_model.dart';
import '../providers/verification_provider.dart';

class VerificationDetailScreen extends ConsumerStatefulWidget {
  final VerificationRequest request;
  
  const VerificationDetailScreen({
    Key? key,
    required this.request,
  }) : super(key: key);

  @override
  ConsumerState<VerificationDetailScreen> createState() => _VerificationDetailScreenState();
}

class _VerificationDetailScreenState extends ConsumerState<VerificationDetailScreen> {
  bool _isApproving = false;
  bool _isRejecting = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.request.name),
        backgroundColor: const Color(0xFF8B5CF6),
      ),
      body: Column(
        children: [
          // Images Section
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Info
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.request.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'User ID: ${widget.request.userId}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Images Comparison
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Verification Images',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Image Comparison
                        Row(
                          children: [
                            // Profile Image
                            Expanded(
                              child: Column(
                                children: [
                                  const Text('Profile Image'),
                                  const SizedBox(height: 8),
                                  _buildImageWithZoom(widget.request.profileImageUrl),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Verification Image
                            Expanded(
                              child: Column(
                                children: [
                                  const Text('Verification Image'),
                                  const SizedBox(height: 8),
                                  _buildImageWithZoom(widget.request.verificationUrl),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Action Buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isRejecting || _isApproving 
                        ? null 
                        : _rejectVerification,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isRejecting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('REJECT'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isRejecting || _isApproving 
                        ? null 
                        : _approveVerification,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isApproving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('APPROVE'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildImageWithZoom(String imageUrl) {
    return GestureDetector(
      onTap: () => _showFullScreenImage(imageUrl),
      child: Container(
        height: 300,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        clipBehavior: Clip.antiAlias,
        child: imageUrl.isNotEmpty
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => 
                    _buildErrorImage(),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _buildLoadingImage();
                },
              )
            : _buildErrorImage(),
      ),
    );
  }
  
  Widget _buildErrorImage() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.broken_image, size: 48, color: Colors.grey),
            const SizedBox(height: 8),
            Text(
              'Image not available',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLoadingImage() {
    return Container(
      color: Colors.grey[100],
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
  
  void _showFullScreenImage(String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.network(
                imageUrl,
                errorBuilder: (context, error, stackTrace) => 
                    _buildErrorImage(),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Future<void> _approveVerification() async {
    setState(() {
      _isApproving = true;
    });
    
    try {
      final success = await ref
          .read(verificationProvider.notifier)
          .updateVerificationStatus(widget.request.userId, true);
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Verification approved successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to approve verification'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isApproving = false;
        });
      }
    }
  }
  
  Future<void> _rejectVerification() async {
    setState(() {
      _isRejecting = true;
    });
    
    try {
      final success = await ref
          .read(verificationProvider.notifier)
          .updateVerificationStatus(widget.request.userId, false);
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Verification rejected'),
              backgroundColor: Colors.orange,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to reject verification'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRejecting = false;
        });
      }
    }
  }
}
