import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'task_board_page.dart'; 
import 'plan_selection_page.dart';
import 'workspace_theme.dart';

class WorkspaceSelectPage extends StatefulWidget {
  const WorkspaceSelectPage({super.key});
  @override
  State<WorkspaceSelectPage> createState() => _WorkspaceSelectPageState();
}

class _WorkspaceSelectPageState extends State<WorkspaceSelectPage> {
  // ユーザー情報をより安全に取得
  auth.User? get currentUser => auth.FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    // 1. ログインチェック（ログインしていなければ処理を中断）
    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text("Please Login / ログインしてください")));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8), 
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Column(
          children: [
            const Text('marcheZ / SELECT BOX', 
              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B263B), fontSize: 16)),
            Text('ボックス選択', 
              style: TextStyle(color: const Color(0xFF1B263B).withValues(alpha: 0.5), fontSize: 10)),
          ],
        ),
      ),
      // 2. ユーザーのプラン状態を取得[cite: 5]
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).snapshots(),
        builder: (context, userSnap) {
          // ユーザーデータの読み込み待ち
          if (userSnap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          
          final userData = userSnap.data?.data() as Map<String, dynamic>? ?? {};
          final bool isPremium = userData['isPremium'] ?? false;

          return StreamBuilder<QuerySnapshot>(
            // 3. 自分のBOX一覧を取得（自分がオーナー、もしくは参加しているBOXを表示）[cite: 5]
            stream: FirebaseFirestore.instance
                .collection('groups')
                .where('memberUids', arrayContains: currentUser!.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              
              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }

              final docs = snapshot.data?.docs ?? [];
              
              // 自分がオーナーのBOX数をカウント（制限判定用）[cite: 5]
              int myOwnedBoxCount = 0;
              for (var doc in docs) {
                final d = doc.data() as Map<String, dynamic>;
                if (d['ownerUid'] == currentUser!.uid) myOwnedBoxCount++;
              }

              return GridView.builder(
                padding: const EdgeInsets.all(24),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isMobile ? 2 : 4, 
                    crossAxisSpacing: 20, 
                    mainAxisSpacing: 20, 
                    childAspectRatio: 1.5), 
                itemCount: docs.length + 3, 
                itemBuilder: (context, index) {
                  if (index < docs.length) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    return _buildBoxCard(context, data, docs[index].id, isMobile); 
                  }

                  int functionIndex = index - docs.length;
                  if (functionIndex == 0) {
                    return _buildFunctionCard(
                      context, 
                      icon: Icons.add, 
                      label: "Create BOX", 
                      subLabel: "BOXを作成",
                      isMobile: isMobile,
                      onTap: () => _handleCreateBoxClick(context, myOwnedBoxCount, isPremium)
                    );
                  } else if (functionIndex == 1) {
                    return _buildPlanCard(context, isMobile, isPremium);
                  } else {
                    return _buildFunctionCard(
                      context, 
                      icon: Icons.add_link, 
                      label: "Join via ID", 
                      subLabel: "招待に参加",
                      isMobile: isMobile,
                      onTap: () => _showJoinBoxDialog(context)
                    );
                  }
                },
              );
            },
          );
        }
      ),
    );
  }

  void _handleCreateBoxClick(BuildContext context, int count, bool isPremium) {
    int limit = isPremium ? 10 : 1; // 制限設定[cite: 4]

    if (count >= limit) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("BOX limit reached ($limit). Upgrade to create more!"))
      );
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => PlanSelectionPage(isCurrentPremium: isPremium)
      ));
    } else {
      _showCreateDialog(context);
    }
  }

  Widget _buildPlanCard(BuildContext context, bool isMobile, bool isPremium) {
    return _buildFunctionCard(
      context,
      icon: isPremium ? Icons.workspace_premium : Icons.workspace_premium_outlined,
      label: isPremium ? "Pro Plan" : "Change Plan",
      subLabel: isPremium ? "Proプラン" : "プランを変更",
      isMobile: isMobile,
      iconColor: isPremium ? Colors.orange : Colors.grey,
      onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (_) => PlanSelectionPage(isCurrentPremium: isPremium)
      )),
    );
  }

  Widget _buildFunctionCard(BuildContext context, {
    required IconData icon, 
    required String label, 
    required String subLabel,
    required VoidCallback onTap, 
    required bool isMobile, 
    Color iconColor = Colors.grey
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(color: Colors.white60, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: isMobile ? 24 : 28), 
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: Colors.grey, fontSize: isMobile ? 9 : 10, fontWeight: FontWeight.bold)),
            Text(subLabel, style: TextStyle(color: Colors.grey.withValues(alpha: 0.6), fontSize: isMobile ? 7 : 8)),
          ],
        ),
      ),
    );
  }

  Widget _buildBoxCard(BuildContext context, Map<String, dynamic> data, String docId, bool isMobile) {
    final theme = WorkspaceTheme.of(data['type'] as String?);
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => ImprovedTaskBoardPage(groupId: docId, groupName: data['name'] ?? "BOX")
        ));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.primary.withValues(alpha: 0.15)),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(theme.boxIcon, color: theme.primary, size: isMobile ? 18 : 20),
            const SizedBox(height: 4),
            Text(data['name'] ?? "Untitled", style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 11 : 12), textAlign: TextAlign.center), 
            const SizedBox(height: 2),
            Text("ID: $docId", style: TextStyle(fontSize: isMobile ? 6 : 7, color: Colors.grey)), 
          ],
        ),
      ),
    );
  }

  void _showJoinBoxDialog(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(context: context, builder: (context) => AlertDialog(
      title: const Text("Join via BOX ID"),
      content: TextField(controller: ctrl, decoration: const InputDecoration(hintText: "Enter BOX ID")),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(onPressed: () async {
          if (ctrl.text.isNotEmpty && currentUser != null) {
            await FirebaseFirestore.instance.collection('groups').doc(ctrl.text.trim()).update({
              'memberUids': FieldValue.arrayUnion([currentUser!.uid])
            });
            if (mounted) Navigator.pop(context);
          }
        }, child: const Text("Join")),
      ],
    ));
  }

  void _showCreateDialog(BuildContext context) {
    String name = "";
    String selectedType = WorkspaceType.family; // デフォルトはFamily（先に選ばせて自己選別を促す）

    showDialog(context: context, builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        final theme = WorkspaceTheme.of(selectedType);
        return AlertDialog(
          title: const Text("Create BOX / BOXを作成"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "どんな用途で使いますか？",
                  style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Row(
                  children: WorkspaceTheme.all.map((t) {
                    final isSelected = selectedType == t.type;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: InkWell(
                          onTap: () => setState(() => selectedType = t.type),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? t.primary.withValues(alpha: 0.08) : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? t.primary : Colors.grey.shade300,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(t.boxIcon, color: t.primary, size: 26),
                                const SizedBox(height: 6),
                                Text(t.selectorTitle, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: t.primary)),
                                Text(t.selectorSubtitle, style: TextStyle(fontSize: 10, color: t.primary.withValues(alpha: 0.7))),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                Text(
                  theme.selectorDescription,
                  style: const TextStyle(fontSize: 11, color: Colors.black54, height: 1.4),
                ),
                const SizedBox(height: 16),
                TextField(
                  onChanged: (v) => name = v,
                  decoration: const InputDecoration(hintText: "BOX Name / BOX名"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: theme.primary),
              onPressed: () async {
                if (name.isNotEmpty && currentUser != null) {
                  final createTheme = WorkspaceTheme.of(selectedType);
                  final doc = FirebaseFirestore.instance.collection('groups').doc();
                  await doc.set({
                    'id': doc.id,
                    'name': name,
                    'type': selectedType,
                    'sharedTitle': createTheme.defaultSharedTitle,
                    'doneTitle': createTheme.defaultDoneTitle,
                    'memberUids': [currentUser!.uid],
                    'ownerUid': currentUser!.uid,
                    'createdAt': FieldValue.serverTimestamp(),
                  });
                  if (mounted) Navigator.pop(context);
                }
              },
              child: const Text("Create"),
            ),
          ],
        );
      },
    ));
  }
}