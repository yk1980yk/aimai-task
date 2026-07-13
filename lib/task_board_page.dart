import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; 
import 'package:confetti/confetti.dart'; 
import 'task_model.dart';
import 'workspace_theme.dart';

class ImprovedTaskBoardPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  const ImprovedTaskBoardPage({super.key, required this.groupId, required this.groupName});

  @override
  State<ImprovedTaskBoardPage> createState() => _ImprovedTaskBoardPageState();
}

class _ImprovedTaskBoardPageState extends State<ImprovedTaskBoardPage> {
  late ConfettiController _confettiController;

  // 🎉 ポイントの節目（この値を跨いだらお祝いポップアップを出す）
  static const List<int> _milestones = [10, 30, 50, 100, 200, 300, 500, 750, 1000, 1500, 2000, 3000, 5000, 10000];

  // before〜after の間で跨いだ最大の節目を返す（無ければnull）
  int? _highestMilestoneCrossed(int before, int after) {
    int? result;
    for (final m in _milestones) {
      if (before < m && after >= m) {
        result = m;
      }
    }
    return result;
  }

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1, milliseconds: 500));
  }

  @override
  void dispose() {
    _confettiController.dispose(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('groups').doc(widget.groupId).snapshots(),
      builder: (context, groupSnap) {
        if (!groupSnap.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final groupData = groupSnap.data!.data() as Map<String, dynamic>? ?? {};
        final theme = WorkspaceTheme.of(groupData['type'] as String?);
        final sharedTitle = groupData['sharedTitle'] ?? theme.defaultSharedTitle;
        final doneTitle = groupData['doneTitle'] ?? theme.defaultDoneTitle;

        return Scaffold(
          backgroundColor: theme.background,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: theme.primary), 
              onPressed: () => Navigator.pop(context)
            ),
            title: Text(widget.groupName, style: TextStyle(color: theme.primary, fontWeight: FontWeight.bold, fontSize: isMobile ? 16 : 18)),
            actions: [ _buildTeamScoreChip(context, theme, isMobile) ],
          ),
          body: Stack(
            children: [
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('groups').doc(widget.groupId).collection('columns').orderBy('createdAt').snapshots(),
                builder: (context, colSnap) {
                  if (!colSnap.hasData) return const Center(child: CircularProgressIndicator());
                  final columns = colSnap.data!.docs;

                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ListView(
                      children: [
                        _buildQuickTutorial(context, theme, isMobile),
                        const SizedBox(height: 16),
                        
                        isMobile
                            ? Column(
                                children: [
                                  _buildDropColumn(context, sharedTitle, 'todo', theme.accent, 'sharedTitle', isMobile, boardTheme: theme),
                                  ...columns.map((col) {
                                    final data = col.data() as Map<String, dynamic>;
                                    return _buildDropColumn(context, "${data['name']} (${data['personalPoints'] ?? 0} ${theme.pointUnitShort})", col.id, theme.primary, 'columnName', isMobile, colId: col.id, currentPoints: data['personalPoints'] ?? 0, boardTheme: theme);
                                  }),
                                  _buildAddColumnButton(context, isMobile),
                                  _buildDropColumn(context, doneTitle, 'done', Colors.orange, 'doneTitle', isMobile, boardTheme: theme),
                                ],
                              )
                            : Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(width: 280, child: _buildDropColumn(context, sharedTitle, 'todo', theme.accent, 'sharedTitle', isMobile, boardTheme: theme)),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Wrap(
                                      alignment: WrapAlignment.start,
                                      spacing: 16,
                                      runSpacing: 16,
                                      children: [
                                        ...columns.map((col) {
                                          final data = col.data() as Map<String, dynamic>;
                                          return SizedBox(width: 280, child: _buildDropColumn(context, "${data['name']} (${data['personalPoints'] ?? 0} ${theme.pointUnitShort})", col.id, theme.primary, 'columnName', isMobile, colId: col.id, currentPoints: data['personalPoints'] ?? 0, boardTheme: theme));
                                        }),
                                        _buildAddColumnButton(context, isMobile),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  SizedBox(
                                    width: 280, 
                                    child: _buildDropColumn(context, doneTitle, 'done', Colors.orange, 'doneTitle', isMobile, boardTheme: theme)
                                  ),
                                ],
                              ),
                      ],
                    ),
                  );
                },
              ),
              
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive, 
                  shouldLoop: false,
                  colors: const [
                    Colors.orange,
                    Colors.teal,
                    Colors.blue,
                    Colors.yellow,
                    Colors.pink,
                    Colors.green,
                  ], 
                  numberOfParticles: 35, 
                  gravity: 0.25, 
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: theme.primary, 
            child: const Icon(Icons.add, color: Colors.white), 
            onPressed: () => _showAddTaskDialog(context, theme)
          ),
        );
      },
    );
  }

  // --- チュートリアルUIの追加モジュール（Family/Workでテキスト・色を出し分け） ---
  Widget _buildQuickTutorial(BuildContext context, WorkspaceTheme theme, bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.primary.withValues(alpha: 0.15), width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: theme.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                theme.tutorialHeader,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: theme.primary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          isMobile
              ? Column(
                  children: [
                    _buildStepItem(theme.step1Title, theme.step1Desc, theme.accent),
                    const Icon(Icons.arrow_downward, size: 14, color: Colors.grey),
                    _buildStepItem(theme.step2Title, theme.step2Desc, theme.primary),
                    const Icon(Icons.arrow_downward, size: 14, color: Colors.grey),
                    _buildStepItem(theme.step3Title, theme.step3Desc, Colors.orange),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: _buildStepItem(theme.step1Title, theme.step1Desc, theme.accent)),
                    const Icon(Icons.arrow_forward, size: 14, color: Colors.grey),
                    Expanded(child: _buildStepItem(theme.step2Title, theme.step2Desc, theme.primary)),
                    const Icon(Icons.arrow_forward, size: 14, color: Colors.grey),
                    Expanded(child: _buildStepItem(theme.step3Title, theme.step3Desc, Colors.orange)),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildStepItem(String title, String description, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
      child: Column(
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color, letterSpacing: 1.0)),
          const SizedBox(height: 4),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, color: Colors.black54, height: 1.3, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamScoreChip(BuildContext context, WorkspaceTheme theme, bool isMobile) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('groups').doc(widget.groupId).collection('tasks').where('status', isEqualTo: 'done').snapshots(),
      builder: (context, snapshot) {
        int total = 0;
        if (snapshot.hasData) {
          for (var d in snapshot.data!.docs) {
            total += (d.data() as Map<String, dynamic>)['points'] as int? ?? 0;
          }
        }
        return Center(
          child: Padding(
            padding: EdgeInsets.only(right: isMobile ? 8 : 16),
            child: InkWell(
              onTap: () => _showTeamReportDialog(context, theme, total),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.orange, width: 1.5)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bar_chart, color: Colors.orange, size: 16),
                    const SizedBox(width: 4),
                    Text("TOTAL: $total ${theme.pointUnitShort}", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: isMobile ? 11 : 13)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showTeamReportDialog(BuildContext context, WorkspaceTheme theme, int totalScore) {
    String selectedPeriod = 'this_month';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('groups').doc(widget.groupId).collection('columns').snapshots(),
          builder: (context, colSnapshot) {
            if (!colSnapshot.hasData) {
              return const AlertDialog(content: SizedBox(height: 100, child: Center(child: CircularProgressIndicator())));
            }

            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('groups').doc(widget.groupId).collection('tasks').where('status', isEqualTo: 'done').snapshots(),
              builder: (context, taskSnapshot) {
                if (!taskSnapshot.hasData) {
                  return const AlertDialog(content: SizedBox(height: 100, child: Center(child: CircularProgressIndicator())));
                }

                final now = DateTime.now();
                final doneTasks = taskSnapshot.data!.docs;

                Map<String, Map<String, dynamic>> memberStats = {};
                int periodTotalScore = 0;

                for (var col in colSnapshot.data!.docs) {
                  final colData = col.data() as Map<String, dynamic>;
                  final colId = col.id;
                  memberStats[colId] = {
                    'name': colData['name'] ?? 'No Name',
                    'points': 0,
                    'quickCount': 0,
                    'normalCount': 0,
                    'importantCount': 0,
                  };
                }

                for (var taskDoc in doneTasks) {
                  final task = taskDoc.data() as Map<String, dynamic>;
                  final createdAtTimestamp = task['createdAt'] as Timestamp?;
                  
                  // 作成日時がまだFirestore上で確定していない暫定状態のタスクは現在時刻として扱う安全ロジック
                  final taskDate = createdAtTimestamp != null ? createdAtTimestamp.toDate() : DateTime.now();

                  if (selectedPeriod == 'this_month') {
                    if (taskDate.year != now.year || taskDate.month != now.month) {
                      continue;
                    }
                  }

                  final String? fromColId = task['fromColId']; 
                  final int pts = task['points'] as int? ?? 0;
                  final String priority = task['priority'] ?? 'Normal';

                  // 💡 fromColId が割り振られている有効なタスクのポイントのみを、この期間の総スコアに合算します
                  if (fromColId != null && memberStats.containsKey(fromColId)) {
                    periodTotalScore += pts;
                    memberStats[fromColId]!['points'] = (memberStats[fromColId]!['points'] as int) + pts;
                    if (priority == 'Quick') {
                      memberStats[fromColId]!['quickCount'] = (memberStats[fromColId]!['quickCount'] as int) + 1;
                    } else if (priority == 'Important') {
                      memberStats[fromColId]!['importantCount'] = (memberStats[fromColId]!['importantCount'] as int) + 1;
                    } else {
                      memberStats[fromColId]!['normalCount'] = (memberStats[fromColId]!['normalCount'] as int) + 1;
                    }
                  }
                }

                final memberList = memberStats.values.toList();
                memberList.sort((a, b) => (b['points'] as int).compareTo(a['points'] as int));

                int maxPoints = memberList.isNotEmpty ? memberList.first['points'] as int : 0;

                return AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  title: const Row(
                    children: [
                      Icon(Icons.stars, color: Colors.orange),
                      SizedBox(width: 8),
                      Text("🏆 Contribution Report", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                  content: SizedBox(
                    width: 360,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: selectedPeriod == 'this_month' ? Colors.orange : Colors.grey.shade200,
                                  foregroundColor: selectedPeriod == 'this_month' ? Colors.white : Colors.black87,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: () => setDialogState(() => selectedPeriod = 'this_month'),
                                child: const Text("今月 (This Month)", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: selectedPeriod == 'all' ? Colors.orange : Colors.grey.shade200,
                                  foregroundColor: selectedPeriod == 'all' ? Colors.white : Colors.black87,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: () => setDialogState(() => selectedPeriod = 'all'),
                                child: const Text("全期間 (All Time)", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
                          ),
                          child: Column(
                            children: [
                              Text(selectedPeriod == 'this_month' ? "今月のチーム総ポイント" : "全期間のチーム総ポイント", style: const TextStyle(fontSize: 11, color: Colors.grey)),
                              const SizedBox(height: 4),
                              Text("$periodTotalScore ${theme.pointUnitShort}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text("👑 Member Contribution/メンバー貢献度", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.primary)),
                        const SizedBox(height: 8),
                        
                        if (memberList.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Center(child: Text("No members found.", style: TextStyle(color: Colors.grey, fontSize: 12))),
                          )
                        else
                          Flexible(
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: memberList.length,
                              itemBuilder: (context, index) {
                                final member = memberList[index];
                                final name = member['name'] as String;
                                final points = member['points'] as int;
                                final qCount = member['quickCount'] as int;
                                final nCount = member['normalCount'] as int;
                                final iCount = member['importantCount'] as int;

                                Widget medalWidget;
                                if (index == 0 && points > 0) {
                                  medalWidget = const Text("🥇", style: TextStyle(fontSize: 18));
                                } else if (index == 1 && points > 0) {
                                  medalWidget = const Text("🥈", style: TextStyle(fontSize: 18));
                                } else if (index == 2 && points > 0) {
                                  medalWidget = const Text("🥉", style: TextStyle(fontSize: 18));
                                } else {
                                  medalWidget = Text("  ${index + 1} ", style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold));
                                }

                                bool isMVP = points > 0 && points == maxPoints;

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: isMVP ? Colors.orange.withValues(alpha: 0.5) : Colors.grey.shade100, width: isMVP ? 1.5 : 1.0),
                                    boxShadow: isMVP ? [BoxShadow(color: Colors.orange.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))] : null,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          medalWidget,
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Row(
                                              children: [
                                                Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: theme.primary)),
                                                if (isMVP) ...[
                                                  const SizedBox(width: 6),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                    decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(6)),
                                                    child: const Text("👑 MVP", style: TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold)),
                                                  ),
                                                ]
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(color: Colors.teal.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
                                            child: Text("$points ${theme.pointUnitShort}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.teal)),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          const SizedBox(width: 26),
                                          _buildPriorityBadge("🟢 ${theme.priorityLabels['Quick']}: $qCount"),
                                          const SizedBox(width: 8),
                                          _buildPriorityBadge("🟡 ${theme.priorityLabels['Normal']}: $nCount"),
                                          const SizedBox(width: 8),
                                          _buildPriorityBadge("🔴 ${theme.priorityLabels['Important']}: $iCount"),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Close", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4)),
      child: Text(label, style: const TextStyle(fontSize: 9, color: Colors.black54, fontWeight: FontWeight.w500)),
    );
  }

  // 🎉 ポイントの節目達成時に、画面内お祝いポップアップ＋紙吹雪を出す
  void _showMilestoneCelebration(BuildContext context, WorkspaceTheme theme, int milestone, String memberName) {
    // 通常の完了紙吹雪よりも派手にするため、もう一度バーストさせる
    _confettiController.play();

    final displayName = memberName.isNotEmpty ? memberName : 'You';

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              '$displayName reached $milestone${theme.pointUnitShort}!\n($milestone${theme.pointUnitShort}達成！)',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: theme.primary),
            ),
            const SizedBox(height: 10),
            Text(
              theme.milestoneSubtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Colors.black54, height: 1.4),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            ),
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Nice! / やったね', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildDropColumn(BuildContext context, String title, String statusKey, Color themeColor, String fieldKey, bool isMobile, {String? colId, int currentPoints = 0, WorkspaceTheme? boardTheme}) {
    final theme = boardTheme ?? WorkspaceTheme.work;
    return Container(
      margin: isMobile ? const EdgeInsets.only(bottom: 16) : EdgeInsets.zero,
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(16), 
        border: Border.all(color: themeColor.withValues(alpha: 0.2)), 
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))]
      ),
      child: DragTarget<Map<String, dynamic>>(
        onAcceptWithDetails: (details) async {
          final dragData = details.data;
          // 💡 もしタスクが「すでに誰かのフォルダ（colId）に所属していた」状態で宝箱へドロップされた場合のみ、
          // ドラッグデータ内の fromColId を優先し、Shared BOXからの直行等の場合は新しいコラムID（nullまたは現在のcolId）を割り当てます。
          final resolvedFromColId = dragData['fromColId'] ?? colId;

          await FirebaseFirestore.instance.collection('groups').doc(widget.groupId).collection('tasks').doc(dragData['taskId']).update({
            'status': statusKey,
            'fromColId': resolvedFromColId,
          });

          if (statusKey == 'done' && resolvedFromColId != null) {
            _confettiController.play();

            final colRef = FirebaseFirestore.instance.collection('groups').doc(widget.groupId).collection('columns').doc(resolvedFromColId);
            final int taskPts = dragData['taskPoints'] as int? ?? 0;
            int? crossedMilestone;
            String memberName = '';

            // 💡 増加前→増加後のポイントをトランザクションで取得し、節目を跨いだかどうかを判定します
            await FirebaseFirestore.instance.runTransaction((tx) async {
              final snap = await tx.get(colRef);
              final data = snap.data() as Map<String, dynamic>? ?? {};
              final int before = (data['personalPoints'] ?? 0) as int;
              final int after = before + taskPts;
              memberName = (data['name'] ?? '') as String;
              crossedMilestone = _highestMilestoneCrossed(before, after);
              tx.update(colRef, {'personalPoints': after});
            });

            if (crossedMilestone != null && context.mounted) {
              _showMilestoneCelebration(context, theme, crossedMilestone!, memberName);
            }
          }
        },
        builder: (context, _, __) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: themeColor), overflow: TextOverflow.ellipsis)),
                  IconButton(icon: const Icon(Icons.edit, size: 14), onPressed: () => _showRenameDialog(context, title, fieldKey, colId)),
                  if (colId != null) IconButton(icon: const Icon(Icons.delete_outline, size: 14), onPressed: () => _deleteColumn(colId)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 💡 colId（現在のフォルダID）をしっかりとタスクリストへパスするように修正！
                  _buildTaskList(statusKey, colId, isMobile, theme),
                  if (statusKey == 'todo')
                    Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 4, left: 10, right: 10),
                      child: TextButton.icon(
                        onPressed: () => _showAddTaskDialog(context, theme),
                        icon: Icon(Icons.add, size: 16, color: theme.primary),
                        label: Text(
                          "Add a task (タスクを追加)", 
                          style: TextStyle(color: theme.primary, fontSize: 12, fontWeight: FontWeight.bold)
                        ),
                        style: TextButton.styleFrom(
                          minimumSize: const Size(double.infinity, 38),
                          backgroundColor: theme.primary.withValues(alpha: 0.05),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList(String statusKey, String? currentColId, bool isMobile, WorkspaceTheme theme) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('groups').doc(widget.groupId).collection('tasks').where('status', isEqualTo: statusKey).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const SizedBox(height: 100, child: Center(child: Text("No tasks", style: TextStyle(color: Colors.grey, fontSize: 11))));
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(), 
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final task = TaskModel.fromSnapshot(docs[index]);
            
            // 💡 既存のFirestoreデータにすでに 'fromColId' が書き込まれている場合はそれを使い、
            // まだ無い（新しくドラッグされた）場合は現在配置されているフォルダのID（currentColId）をDraggableデータに乗せて引き渡します。
            final String? taskFromColId = (docs[index].data() as Map<String, dynamic>?)?['fromColId'] ?? currentColId;

            return Draggable<Map<String, dynamic>>(
              data: {'taskId': task.id, 'fromColId': taskFromColId, 'taskPoints': task.points},
              feedback: Material(elevation: 4, child: Container(width: 200, padding: const EdgeInsets.all(8), color: Colors.white, child: Text(task.title))),
              child: _buildTaskCard(task, docs[index].reference, statusKey, isMobile, theme),
            );
          },
        );
      },
    );
  }

  Widget _buildTaskCard(TaskModel task, DocumentReference ref, String status, bool isMobile, WorkspaceTheme theme) {
    Color attrColor = task.priority == 'Quick' ? Colors.green : (task.priority == 'Important' ? Colors.red : Colors.orange);
    String priorityLabel = theme.priorityLabels[task.priority] ?? task.priority;
    String dateStr = task.dueDate != null ? DateFormat('MM/dd').format(task.dueDate!) : "";

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(10), 
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: attrColor, width: 4))
        ),
        padding: const EdgeInsets.only(left: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                Text("${task.points}${theme.pointUnitShort}", style: const TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Text(priorityLabel, style: TextStyle(fontSize: 8, color: attrColor, fontWeight: FontWeight.bold)),
                  if (dateStr.isNotEmpty) ...[
                    const SizedBox(width: 8), 
                    const Icon(Icons.calendar_month, size: 10, color: Colors.grey), 
                    Text(dateStr, style: const TextStyle(fontSize: 8, color: Colors.grey))
                  ],
                ]),
                IconButton(icon: const Icon(Icons.delete_outline, size: 14, color: Colors.redAccent), padding: EdgeInsets.zero, constraints: const BoxConstraints(), onPressed: () => ref.delete()),
              ],
            ),
            if (task.memo.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(task.memo, style: const TextStyle(fontSize: 10, color: Colors.blueGrey, fontStyle: FontStyle.italic)),
            ],
            const SizedBox(height: 6),
            LinearProgressIndicator(value: task.progress / 100, backgroundColor: Colors.grey.shade100, color: Colors.teal.shade300, minHeight: 2),
          ],
        ),
      ),
    );
  }

  Widget _buildAddColumnButton(BuildContext context, bool isMobile) {
    return InkWell(
      onTap: () => _showAddColumnDialog(context),
      child: Container(
        width: isMobile ? double.infinity : 280, 
        height: 60,            
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.4), 
          borderRadius: BorderRadius.circular(16), 
          border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid, width: 1.5)
        ),
        child: const Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline, color: Colors.grey, size: 20),
              SizedBox(width: 8),
              Text("+ Add Board", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          )
        ),
      ),
    );
  }

  void _showAddColumnDialog(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(context: context, builder: (context) => AlertDialog(
      title: const Text("Add Board"),
      content: TextField(controller: ctrl, decoration: const InputDecoration(hintText: "Name")),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(onPressed: () async {
          if (ctrl.text.isNotEmpty) {
            await FirebaseFirestore.instance.collection('groups').doc(widget.groupId).collection('columns').add({'name': ctrl.text, 'personalPoints': 0, 'createdAt': FieldValue.serverTimestamp()});
            if (context.mounted) Navigator.pop(context);
          }
        }, child: const Text("Add")),
      ],
    ));
  }

  void _showRenameDialog(BuildContext context, String current, String key, String? colId) {
    final ctrl = TextEditingController(text: current);
    showDialog(context: context, builder: (context) => AlertDialog(
      title: const Text("Rename"),
      content: TextField(controller: ctrl),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(onPressed: () async {
          if (colId != null) {
            await FirebaseFirestore.instance.collection('groups').doc(widget.groupId).collection('columns').doc(colId).update({'name': ctrl.text});
          } else {
            await FirebaseFirestore.instance.collection('groups').doc(widget.groupId).update({key: ctrl.text});
          }
          if (context.mounted) Navigator.pop(context);
        }, child: const Text("Update")),
      ],
    ));
  }

  void _deleteColumn(String colId) => FirebaseFirestore.instance.collection('columns').doc(colId).delete();

  void _showAddTaskDialog(BuildContext context, WorkspaceTheme theme) {
    final ctrlTitle = TextEditingController();
    final ctrlMemo = TextEditingController();
    int pts = 1; double prog = 0.0; String attr = 'Normal';
    DateTime? selectedDate;

    showDialog(context: context, builder: (context) => StatefulBuilder(builder: (context, setState) => AlertDialog(
      title: const Text("New Task"),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: ctrlTitle, decoration: const InputDecoration(hintText: "What to do?")),
          DropdownButtonFormField<String>(
            initialValue: attr,
            items: [
              DropdownMenuItem(value: 'Quick', child: Text("🟢 ${theme.priorityLabels['Quick']}")),
              DropdownMenuItem(value: 'Normal', child: Text("🟡 ${theme.priorityLabels['Normal']}")),
              DropdownMenuItem(value: 'Important', child: Text("🔴 ${theme.priorityLabels['Important']}")),
            ],
            onChanged: (v) => setState(() => attr = v!),
          ),
          DropdownButtonFormField<int>(
            initialValue: pts, items: [1,2,3,5,10].map((e)=>DropdownMenuItem(value: e, child: Text("$e ${theme.pointUnitShort}"))).toList(),
            onChanged: (v)=>setState(()=>pts=v!),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            icon: const Icon(Icons.calendar_month),
            label: Text(selectedDate == null ? "Set Due Date" : DateFormat('yyyy/MM/dd').format(selectedDate!)),
            onPressed: () async {
              final date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
              if (date != null) setState(() => selectedDate = date);
            },
          ),
          Slider(value: prog, min: 0, max: 100, divisions: 10, label: "${prog.round()}%", onChanged: (v) => setState(() => prog = v)),
          TextField(controller: ctrlMemo, decoration: const InputDecoration(hintText: "Memo")),
        ]),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")), 
        ElevatedButton(onPressed: () async {
          if (ctrlTitle.text.trim().isEmpty) return;
          await FirebaseFirestore.instance.collection('groups').doc(widget.groupId).collection('tasks').add({
            'title': ctrlTitle.text.trim(), 
            'memo': ctrlMemo.text.trim(), 
            'status': 'todo', 
            'points': pts, 
            'priority': attr, 
            'progress': prog,
            'dueDate': selectedDate != null ? Timestamp.fromDate(selectedDate!) : null,
            'createdAt': FieldValue.serverTimestamp()
          });
          if (context.mounted) Navigator.pop(context);
        }, child: const Text("Post"))
      ],
    )));
  }
}