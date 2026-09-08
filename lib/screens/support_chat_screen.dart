import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/support_message_model.dart';
import '../services/support_chat_service.dart';
import '../theme/app_theme.dart';

// ================================================================
// SUPPORT CHAT SCREEN (NEW — 2026-08-29)
// ================================================================
//
// Wires up the "Help & Support" tile on the Profile screen, which
// previously had no onTap at all. A customer can message the Habio
// team here; messages are stored in Firestore (support_chats
// collection) so they reach whoever is handling support today (via
// the Firebase console) even though there's no admin panel/live
// agent yet -- that's a deliberately deferred, separate build.
// Rather than fake a reply from "support" that never really
// arrives, this screen is upfront about that with a standing note
// at the top instead of a pretend chat partner.
//

class SupportChatScreen extends StatefulWidget {
  const SupportChatScreen({super.key});

  @override
  State<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends State<SupportChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();

    if (text.isEmpty || _sending) {
      return;
    }

    setState(() => _sending = true);
    _controller.clear();

    try {
      await SupportChatService.sendMessage(text);

      if (_scrollController.hasClients) {
        await Future.delayed(const Duration(milliseconds: 100));
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      }
    } on StateError catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final customerId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        title: const Text(
          'Help & Support',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: customerId == null
          ? const Center(child: Text('Please login first.'))
          : SafeArea(
              child: Column(
                children: [
                  _buildInfoBanner(),
                  Expanded(
                    child: StreamBuilder<List<SupportMessageModel>>(
                      stream: SupportChatService.watchMessages(customerId),
                      builder: (context, snapshot) {
                        final messages =
                            snapshot.data ?? const <SupportMessageModel>[];

                        if (snapshot.connectionState ==
                                ConnectionState.waiting &&
                            messages.isEmpty) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: AppTheme.primaryBlue,
                            ),
                          );
                        }

                        if (messages.isEmpty) {
                          return _buildEmptyState();
                        }

                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (_scrollController.hasClients) {
                            _scrollController.jumpTo(
                              _scrollController.position.maxScrollExtent,
                            );
                          }
                        });

                        return ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            return _buildBubble(messages[index]);
                          },
                        );
                      },
                    ),
                  ),
                  _buildComposer(),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.lightBlue,
        borderRadius: BorderRadius.circular(13),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: AppTheme.primaryBlue,
            size: 17,
          ),
          SizedBox(width: 9),
          Expanded(
            child: Text(
              'Send us your question and our team will get back to you here.',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.primaryBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 64,
              width: 64,
              decoration: const BoxDecoration(
                color: AppTheme.lightBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                color: AppTheme.primaryBlue,
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No messages yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Have a question or an issue with a booking? Send us a message below.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // BUBBLE (fixed 2026-08-30) -- previously every message rendered
  // right-aligned/blue regardless of who sent it, so a support
  // reply (once there's a way to write one -- see the note in
  // support_message_model.dart) would have looked identical to the
  // customer's own message. Now the customer's messages stay
  // right-aligned/blue and anything else renders left-aligned/white,
  // labelled "Habio Support".
  // ------------------------------------------------------------

  Widget _buildBubble(SupportMessageModel message) {
    final bool isCustomer = message.isFromCustomer;

    final bubble = Container(
      constraints: const BoxConstraints(maxWidth: 280),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isCustomer ? AppTheme.primaryBlue : Colors.white,
        border: isCustomer
            ? null
            : Border.all(color: const Color(0xFFE5E8EE)),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(isCustomer ? 16 : 4),
          bottomRight: Radius.circular(isCustomer ? 4 : 16),
        ),
      ),
      child: Text(
        message.text,
        style: TextStyle(
          color: isCustomer ? Colors.white : AppTheme.textPrimary,
          fontSize: 14,
          height: 1.4,
        ),
      ),
    );

    if (isCustomer) {
      return Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: bubble,
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 3),
              child: Text(
                'Habio Support',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
            bubble,
          ],
        ),
      ),
    );
  }

  Widget _buildComposer() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              minLines: 1,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Type your message…',
                filled: true,
                fillColor: AppTheme.background,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _send(),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 46,
            width: 46,
            child: ElevatedButton(
              onPressed: _sending ? null : _send,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.zero,
                shape: const CircleBorder(),
              ),
              child: _sending
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send_rounded, size: 19),
            ),
          ),
        ],
      ),
    );
  }
}
