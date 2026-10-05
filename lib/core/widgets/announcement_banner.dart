import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// ================================================================
// ANNOUNCEMENT BANNER (NEW — 2026-10-02)
// ================================================================
//
// Shows the single most recent active admin announcement targeting
// customers (or 'BOTH'), written from the admin panel's new
// Announcements screen (§4C's "Broadcast & promotions" brainstorm
// item -- festival offers, maintenance notices). Dismissing it is
// session-only (a local Set<String>, not persisted to Firestore) --
// an announcement the admin is still running should keep showing on
// a fresh app launch, the same way the existing fee-waiver/referral
// popups on this screen already reappear each launch until their own
// real condition stops being true.
//
// Deliberately queries with ONLY `where('isActive', isEqualTo: true)`
// and no `orderBy` -- adding an orderBy on a different field here
// would need a new Firestore composite index (same class of issue
// this project has hit before, e.g. the Verification Queue), and
// announcements are always few enough to sort client-side instead.
// Audience filtering (CUSTOMERS vs BOTH) is also done client-side
// for the same reason.
//

class AnnouncementBanner extends StatefulWidget {
  const AnnouncementBanner({super.key});

  @override
  State<AnnouncementBanner> createState() => _AnnouncementBannerState();
}

class _AnnouncementBannerState extends State<AnnouncementBanner> {
  final Set<String> _dismissedIds = {};

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('announcements')
          .where('isActive', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        final docs = List.of(snapshot.data?.docs ?? const []);

        docs.sort((a, b) {
          final aTime = a.data()['createdAt'];
          final bTime = b.data()['createdAt'];
          final aMs = aTime is Timestamp ? aTime.millisecondsSinceEpoch : 0;
          final bMs = bTime is Timestamp ? bTime.millisecondsSinceEpoch : 0;
          return bMs.compareTo(aMs);
        });

        QueryDocumentSnapshot<Map<String, dynamic>>? match;
        for (final d in docs) {
          if (_dismissedIds.contains(d.id)) continue;
          final audience = d.data()['audience'] as String? ?? 'BOTH';
          if (audience == 'CUSTOMERS' || audience == 'BOTH') {
            match = d;
            break;
          }
        }

        if (match == null) return const SizedBox.shrink();

        final data = match.data();
        final id = match.id;
        final title = data['title'] as String? ?? '';
        final body = data['body'] as String? ?? '';

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4E5),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFFD9A0)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.campaign_outlined, color: Color(0xFFB8860B)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        body,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => setState(() => _dismissedIds.add(id)),
                  child: const Padding(
                    padding: EdgeInsets.all(2),
                    child: Icon(Icons.close, size: 18, color: Color(0xFF64748B)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
