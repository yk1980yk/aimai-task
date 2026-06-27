import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; 
import 'task_model.dart';

class ImprovedTaskBoardPage extends StatelessWidget {
  final String groupId;
  final String groupName;
  const ImprovedTaskBoardPage({super.key, required this.groupId, required this.groupName});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1B263B)), 
          onPressed: () => Navigator.pop(context)
        ),
        title: Text(groupName, style: TextStyle(color: const Color(0xFF1B263B), fontWeight: FontWeight.bold, fontSize: isMobile ? 16 : 18)),
        actions: [ _buildTeamScoreChip(isMobile) ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('groups').doc(groupId).snapshots(),
        builder: (context, groupSnap) {
          if (!groupSnap.hasData) return const Center(child: CircularProgressIndicator());
          final groupData = groupSnap.data!.data() as Map<String, dynamic>? ?? {};
          final sharedTitle = groupData['sharedTitle'] ?? '🌊 Shared Market';
          final doneTitle = groupData['doneTitle'] ?? '✨ Treasure Box';

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('groups').doc(groupId).collection('columns').orderBy('createdAt').snapshots(),
            builder: (context, colSnap) {
              if (!colSnap.hasData) return const Center(child: CircularProgressIndicator());
              final columns = colSnap.data!.docs;

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: [
                    // クイックチュートリアルガイド
                    _buildQuickTutorial(context, isMobile),
                    
                    const SizedBox(height: 16),
                    
                    // ボードメインコンテンツ（左・中・右の完全分離独立レイアウト）
                    isMobile
                        ? Column(
                            children: [
                              _buildDropColumn(context, sharedTitle, 'todo', Colors.blueGrey, 'sharedTitle', isMobile),
                              ...columns.map((col) {
                                final data = col.data() as Map<String, dynamic>;
                                return _buildDropColumn(context, "${data['name']} (${data['personalPoints'] ?? 0} pt)", col.id, Colors.teal, 'columnName', isMobile, colId: col.id, currentPoints: data['personalPoints'] ?? 0);
                              }),
                              _buildAddColumnButton(context, isMobile),
                              _buildDropColumn(context, doneTitle, 'done', Colors.orange, 'doneTitle', isMobile),
                            ],
                          )
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 【1. 左端ブロック】 Shared Market 専用（他のコラムが絶対に下に回り込まないように完全固定）
                              SizedBox(width: 280, child: _buildDropColumn(context, sharedTitle, 'todo', Colors.blueGrey, 'sharedTitle', isMobile)),
                              
                              const SizedBox(width: 16),
                              
                              // 【2. 中央ブロック】 メンバー群 ＋ 追加ボタン（ここだけが画面幅に合わせて自動で折り返します）
                              Expanded(
                                child: Wrap(
                                  alignment: WrapAlignment.start,
                                  spacing: 16,
                                  runSpacing: 16,
                                  children: [
                                    ...columns.map((col) {
                                      final data = col.data() as Map<String, dynamic>;
                                      return SizedBox(width: 280, child: _buildDropColumn(context, "${data['name']} (${data['personalPoints'] ?? 0} pt)", col.id, Colors.teal, 'columnName', isMobile, colId: col.id, currentPoints: data['personalPoints'] ?? 0));
                                    }),
                                    _buildAddColumnButton(context, isMobile),
                                  ],
                                ),
                              ),
                              
                              const SizedBox(width: 16),
                              
                              // 【3. 右端ブロック】 一番右に常駐固定される Treasure Box
                              SizedBox(
                                width: 280, 
                                child: _buildDropColumn(context, doneTitle, 'done', Colors.orange, 'doneTitle', isMobile)
                              ),
                            ],
                          ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1B263B), 
        child: const Icon(Icons.add, color: Colors.white), 
        onPressed: () => _showAddTaskDialog(context)
      ),
    );
  }

  // --- チュートリアルUIの追加モジュール ---
  Widget _buildQuickTutorial(BuildContext context, bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.teal.shade100, width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.teal.shade400, size: 18),
              const SizedBox(width: 8),
              const Text(
                "How to play marchez 🚀 (クイックガイド)",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1B263B)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          isMobile
              ? Column(
                  children: [
                    _buildStepItem("1. DROP 🌊", "Put unassigned chores into 'Shared Market'\n(誰の担当でもない雑務をここへ)", Colors.blueGrey),
                    const Icon(Icons.arrow_downward, size: 14, color: Colors.grey),
                    _buildStepItem("2. PICK 🤝", "Drag tasks to your folder when you are free\n(手が空いた人が自分のフォルダへドラッグ)", Colors.teal),
                    const Icon(Icons.arrow_downward, size: 14, color: Colors.grey),
                    _buildStepItem("3. WIN ✨", "Finish tasks to earn Help Points in 'Treasure Box'\n(完了すると宝箱にポイントが貯まります)", Colors.orange),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: _buildStepItem("1. DROP 🌊", "Put unassigned chores into 'Shared Market'\n(誰の担当でもない雑務をここへ)", Colors.blueGrey)),
                    const Icon(Icons.arrow_forward, size: 14, color: Colors.grey),
                    Expanded(child: _buildStepItem("2. PICK 🤝", "Drag tasks to your folder when you are free\n(手が空いた人が自分のフォルダへドラッグ)", Colors.teal)),
                    const Icon(Icons.arrow_forward, size: 14, color: Colors.grey),
                    Expanded(child: _buildStepItem("3. WIN ✨", "Finish tasks to earn Help Points in 'Treasure Box'\n(完了すると宝箱にポイントが貯まります)", Colors.orange)),
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

  Widget _buildTeamScoreChip(bool isMobile) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('groups').doc(groupId).collection('tasks').where('status', isEqualTo: 'done').snapshots(),
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
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.orange, width: 1.5)),
              child: Text("TOTAL: $total", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: isMobile ? 11 : 13)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDropColumn(BuildContext context, String title, String statusKey, Color themeColor, String fieldKey, bool isMobile, {String? colId, int currentPoints = 0}) {
    return Container(
      margin: isMobile ? const EdgeInsets.only(bottom: 16) : EdgeInsets.zero,
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(16), 
        border: Border.all(color: themeColor.withOpacity(0.2)), 
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))]
      ),
      child: DragTarget<Map<String, dynamic>>(
        onAccept: (dragData) async {
          await FirebaseFirestore.instance.collection('groups').doc(groupId).collection('tasks').doc(dragData['taskId']).update({'status': statusKey});
          if (statusKey == 'done' && dragData['fromColId'] != null) {
            await FirebaseFirestore.instance.collection('groups').doc(groupId).collection('columns').doc(dragData['fromColId']).update({'personalPoints': FieldValue.increment(dragData['taskPoints'])});
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
                  _buildTaskList(statusKey, colId, isMobile),
                  if (statusKey == 'todo')
                    Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 4, left: 10, right: 10),
                      child: TextButton.icon(
                        onPressed: () => _showAddTaskDialog(context),
                        icon: const Icon(Icons.add, size: 16, color: Colors.blueGrey),
                        label: const Text(
                          "Add a task (タスクを追加)", 
                          style: TextStyle(color: Colors.blueGrey, fontSize: 12, fontWeight: FontWeight.bold)
                        ),
                        style: TextButton.styleFrom(
                          minimumSize: const Size(double.infinity, 38),
                          backgroundColor: Colors.blueGrey.withOpacity(0.05),
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

  Widget _buildTaskList(String statusKey, String? currentColId, bool isMobile) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('groups').doc(groupId).collection('tasks').where('status', isEqualTo: statusKey).snapshots(),
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
            return Draggable<Map<String, dynamic>>(
              data: {'taskId': task.id, 'fromColId': currentColId, 'taskPoints': task.points},
              feedback: Material(elevation: 4, child: Container(width: 200, padding: const EdgeInsets.all(8), color: Colors.white, child: Text(task.title))),
              child: _buildTaskCard(task, docs[index].reference, statusKey, isMobile),
            );
          },
        );
      },
    );
  }

  Widget _buildTaskCard(TaskModel task, DocumentReference ref, String status, bool isMobile) {
    Color attrColor = task.priority == 'Quick' ? Colors.green : (task.priority == 'Important' ? Colors.red : Colors.orange);
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
                Text("${task.points}pt", style: const TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Text(task.priority, style: TextStyle(fontSize: 8, color: attrColor, fontWeight: FontWeight.bold)),
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
          color: Colors.white.withOpacity(0.4), 
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
            await FirebaseFirestore.instance.collection('groups').doc(groupId).collection('columns').add({'name': ctrl.text, 'personalPoints': 0, 'createdAt': FieldValue.serverTimestamp()});
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
            await FirebaseFirestore.instance.collection('groups').doc(groupId).collection('columns').doc(colId).update({'name': ctrl.text});
          } else {
            await FirebaseFirestore.instance.collection('groups').doc(groupId).update({key: ctrl.text});
          }
          if (context.mounted) Navigator.pop(context);
        }, child: const Text("Update")),
      ],
    ));
  }

  void _deleteColumn(String colId) => FirebaseFirestore.instance.collection('columns').doc(colId).delete();

  void _showAddTaskDialog(BuildContext context) {
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
            value: attr, items: const [DropdownMenuItem(value: 'Quick', child: Text("🟢 Quick")), DropdownMenuItem(value: 'Normal', child: Text("🟡 Normal")), DropdownMenuItem(value: 'Important', child: Text("🔴 Important"))],
            onChanged: (v) => setState(() => attr = v!),
          ),
          DropdownButtonFormField<int>(
            value: pts, items: [1,2,3,5,10].map((e)=>DropdownMenuItem(value: e, child: Text("$e pt"))).toList(),
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
          await FirebaseFirestore.instance.collection('groups').doc(groupId).collection('tasks').add({
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