import 'package:flutter/material.dart';

void main() => runApp(AimaiTaskApp());

class AimaiTaskApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FUZZY TASK BOX',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        fontFamily: 'Inter, Roboto, Helvetica, Arial, sans-serif',
      ),
      home: TaskBoard(),
    );
  }
}

// Priority Definitions
enum Priority { high, medium, low }

class Task {
  String id;
  String title;
  int points;
  String fuzzyDeadline;
  double progress;
  Priority priority;
  
  Task({
    required this.id, 
    required this.title, 
    this.points = 10, 
    this.fuzzyDeadline = "Not Set",
    this.progress = 0.0,
    this.priority = Priority.medium,
  });
}

class UserIsland {
  String name;
  Color color;
  List<Task> tasks;
  UserIsland({required this.name, required this.color, required this.tasks});
}

class TaskBoard extends StatefulWidget {
  @override
  _TaskBoardState createState() => _TaskBoardState();
}

class _TaskBoardState extends State<TaskBoard> {
  String searchQuery = ""; 
  
  List<Task> sharedPool = [
    Task(id: '1', title: 'Organize project documents', points: 20, fuzzyDeadline: 'This Week', progress: 0.2, priority: Priority.high),
  ];

  List<UserIsland> islands = [
    UserIsland(name: "My Space", color: Colors.cyanAccent, tasks: []),
    UserIsland(name: "Team Space", color: Colors.pinkAccent, tasks: []),
  ];

  List<Task> treasureChest = [];
  int totalPoints = 0;
  String rewardTitle = "";
  int targetPoints = 100;
  bool _isSuccessEffect = false;

  void _triggerSuccessEffect() {
    setState(() => _isSuccessEffect = true);
    Future.delayed(const Duration(milliseconds: 300), () => setState(() => _isSuccessEffect = false));
  }

  // Edit Island Name and Color
  void _editIslandSettings(UserIsland island) {
    String tempName = island.name;
    Color tempColor = island.color;
    final List<Color> colorOptions = [
      Colors.cyanAccent, Colors.pinkAccent, Colors.yellowAccent, 
      Colors.lightGreenAccent, Colors.orangeAccent, Colors.purpleAccent
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Customize Island'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: TextEditingController(text: island.name),
                onChanged: (value) => tempName = value,
                decoration: const InputDecoration(labelText: "Island Name", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),
              const Text("Pick a theme color"),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: colorOptions.map((c) => GestureDetector(
                  onTap: () => setDialogState(() => tempColor = c),
                  child: Container(
                    width: 35, height: 35,
                    decoration: BoxDecoration(
                      color: c, 
                      border: Border.all(color: tempColor == c ? Colors.black : Colors.transparent, width: 3), 
                      shape: BoxShape.circle
                    ),
                  ),
                )).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              onPressed: () {
                setState(() { island.name = tempName; island.color = tempColor; });
                Navigator.pop(context);
              },
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _addNewIsland() {
    setState(() {
      // 修正済み：余計な 'is' を削除
      islands.add(UserIsland(name: "New Guest", color: Colors.purpleAccent, tasks: []));
    });
  }

  void _removeIsland(UserIsland island) {
    if (island.tasks.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Remove Island?'),
          content: const Text('All tasks in this island will be deleted.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                setState(() => islands.remove(island));
                Navigator.pop(context);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    } else {
      setState(() => islands.remove(island));
    }
  }

  void _showAddTaskDialog() async {
    String name = "";
    int points = 10;
    String selectedFuzzy = "Today";
    Priority selectedPriority = Priority.medium;
    final fuzzyOptions = ["Today", "Tomorrow", "This Week", "Someday"];

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Create New Task'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: "Task Title", border: OutlineInputBorder()),
                  onChanged: (value) => name = value,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedFuzzy,
                  decoration: const InputDecoration(labelText: "Deadline", border: OutlineInputBorder()),
                  items: fuzzyOptions.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                  onChanged: (v) => setDialogState(() => selectedFuzzy = v!),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<Priority>(
                  value: selectedPriority,
                  decoration: const InputDecoration(labelText: "Priority", border: OutlineInputBorder()),
                  items: [
                    const DropdownMenuItem(value: Priority.high, child: Text("🔥 High")),
                    const DropdownMenuItem(value: Priority.medium, child: Text("⚡ Medium")),
                    const DropdownMenuItem(value: Priority.low, child: Text("🍀 Low")),
                  ],
                  onChanged: (v) => setDialogState(() => selectedPriority = v!),
                ),
                const SizedBox(height: 12),
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Points (pt)", border: OutlineInputBorder()),
                  onChanged: (value) => points = int.tryParse(value) ?? 10,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              onPressed: () {
                if (name.isNotEmpty) {
                  setState(() => sharedPool.add(Task(
                    id: DateTime.now().toString(), 
                    title: name, 
                    points: points, 
                    fuzzyDeadline: selectedFuzzy,
                    priority: selectedPriority,
                  )));
                  Navigator.pop(context);
                }
              },
              child: const Text('Add Task', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showRewardSettingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Team Reward'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: "Reward Name (e.g. Pizza Party)", border: OutlineInputBorder()),
              onChanged: (v) => rewardTitle = v,
            ),
            const SizedBox(height: 16),
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Target Points", border: OutlineInputBorder()),
              onChanged: (v) => targetPoints = int.tryParse(v) ?? 100,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () { setState(() => rewardTitle = ""); Navigator.pop(context); }, child: const Text('Reset')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
            onPressed: () => Navigator.pop(context), 
            child: const Text('Done', style: TextStyle(color: Colors.white))
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      color: _isSuccessEffect ? Colors.yellowAccent.withOpacity(0.3) : Colors.transparent,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: const Text('FUZZY TASK BOX', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black)),
          actions: [
            Container(
              width: 200,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: TextField(
                onChanged: (v) => setState(() => searchQuery = v.toLowerCase()),
                decoration: InputDecoration(
                  hintText: "Search...",
                  prefixIcon: const Icon(Icons.search, size: 18),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                ),
              ),
            ),
            IconButton(icon: const Icon(Icons.person_add_alt_1, color: Colors.black), onPressed: _addNewIsland),
            IconButton(icon: const Icon(Icons.card_giftcard, color: Colors.orange), onPressed: _showRewardSettingDialog),
            _buildPointChip(),
          ],
        ),
        body: Column(
          children: [
            if (rewardTitle.isNotEmpty) _buildRewardProgress(),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: islands.map((island) => _buildIslandColumn(island)).toList(),
                    ),
                  ),
                  const VerticalDivider(width: 2, color: Colors.black),
                  _buildDropZone("Shared Pool", sharedPool, Colors.white, Icons.waves, isShared: true),
                  const VerticalDivider(width: 2, color: Colors.black),
                  _buildDropZone("Treasure Chest", treasureChest, Colors.tealAccent.withOpacity(0.15), Icons.auto_awesome, isDone: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardProgress() {
    double progress = (totalPoints / targetPoints).clamp(0.0, 1.0);
    bool isAchieved = totalPoints >= targetPoints;
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isAchieved ? Colors.orange[100] : Colors.white,
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(isAchieved ? Icons.celebration : Icons.stars, color: Colors.orange),
              const SizedBox(width: 8),
              Text(isAchieved ? "Goal Achieved!: $rewardTitle" : "Goal: $rewardTitle", 
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const Spacer(),
              Text("$totalPoints / $targetPoints pt"),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: progress, backgroundColor: Colors.grey[200], color: Colors.orange, minHeight: 10),
        ],
      ),
    );
  }

  Widget _buildIslandColumn(UserIsland island) {
    return SizedBox(
      width: 320,
      child: Stack(
        children: [
          _buildDropZone(island.name, island.tasks, island.color.withOpacity(0.15), Icons.beach_access, 
            onHeaderTap: () => _editIslandSettings(island)),
          PositionNotifier(onDelete: () => _removeIsland(island)),
        ],
      ),
    );
  }

  Widget _buildDropZone(String title, List<Task> taskList, Color bgColor, IconData icon, 
      {bool isDone = false, bool isShared = false, VoidCallback? onHeaderTap}) {
    return DragTarget<Map<String, dynamic>>(
      onWillAccept: (data) => data!['from'] != taskList,
      onAccept: (data) {
        setState(() {
          data['from'].remove(data['task']);
          taskList.add(data['task']);
          if (isDone) {
            totalPoints += data['task'].points as int;
            _triggerSuccessEffect();
          }
        });
      },
      builder: (context, candidateData, rejectedData) => Container(
        width: 320,
        color: candidateData.isNotEmpty ? bgColor.withOpacity(0.4) : bgColor,
        child: Column(
          children: [
            _buildColumnHeader(title, icon, isShared, onHeaderTap, isIsland: !isShared && !isDone),
            Expanded(
              child: ListView.builder(
                itemCount: taskList.length,
                itemBuilder: (context, index) {
                  final task = taskList[index];
                  if (searchQuery.isNotEmpty && !task.title.toLowerCase().contains(searchQuery)) {
                    return const SizedBox.shrink();
                  }
                  return Draggable<Map<String, dynamic>>(
                    data: {'task': task, 'from': taskList},
                    feedback: _buildTaskCard(task, isFeedback: true),
                    childWhenDragging: Opacity(opacity: 0.3, child: _buildTaskCard(task)),
                    child: _buildTaskCard(task, isDone: isDone),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColumnHeader(String title, IconData icon, bool isShared, VoidCallback? onTap, {bool isIsland = false}) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: InkWell(
              onTap: onTap,
              child: Row(
                children: [
                  Icon(icon, size: 20),
                  const SizedBox(width: 8),
                  Flexible(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18), overflow: TextOverflow.ellipsis)),
                  if (isIsland) const Padding(padding: EdgeInsets.only(left: 4), child: Icon(Icons.palette_outlined, size: 14, color: Colors.grey)),
                ],
              ),
            ),
          ),
          if (isShared) IconButton(icon: const Icon(Icons.add_box), onPressed: _showAddTaskDialog),
        ],
      ),
    );
  }

  Widget _buildTaskCard(Task task, {bool isFeedback = false, bool isDone = false}) {
    Color priorityColor = task.priority == Priority.high ? Colors.redAccent : (task.priority == Priority.medium ? Colors.orangeAccent : Colors.lightGreen);

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 280,
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isDone ? Colors.grey[100] : Colors.white,
          border: Border.all(color: Colors.black, width: 2),
          borderRadius: BorderRadius.circular(8),
          boxShadow: isFeedback || isDone ? [] : const [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
        ),
        child: Stack(
          children: [
            Positioned(top: 10, right: 10, child: Container(width: 8, height: 8, decoration: BoxDecoration(color: priorityColor, shape: BoxShape.circle))),
            Column(
              children: [
                ListTile(
                  title: Text(task.title, style: TextStyle(fontWeight: FontWeight.bold, decoration: isDone ? TextDecoration.lineThrough : null)),
                  subtitle: Text("Due: ${task.fuzzyDeadline}", style: const TextStyle(fontSize: 12, color: Colors.blueGrey, fontWeight: FontWeight.bold)),
                  trailing: Text('${task.points}pt', style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.orange)),
                ),
                if (!isDone)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: SliderTheme(
                            data: SliderThemeData(
                              trackHeight: 4,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                              activeTrackColor: Colors.cyan,
                              inactiveTrackColor: Colors.grey[200],
                              thumbColor: Colors.black,
                            ),
                            child: Slider(
                              value: task.progress,
                              onChanged: (val) => setState(() => task.progress = val),
                            ),
                          ),
                        ),
                        Text("${(task.progress * 100).toInt()}%", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                if (isDone || task.progress == 1.0)
                   Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(task.progress == 1.0 ? "🎉 Nice Work!" : "Completed", style: const TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPointChip() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.amberAccent, border: Border.all(color: Colors.black, width: 2),
            borderRadius: BorderRadius.circular(8), boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(2, 2))],
          ),
          child: Text('TEAM KARMA: $totalPoints', style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

class PositionNotifier extends StatelessWidget {
  final VoidCallback onDelete;
  const PositionNotifier({required this.onDelete});
  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 5,
      top: 5,
      child: IconButton(
        icon: const Icon(Icons.close, size: 18, color: Colors.grey),
        onPressed: onDelete,
      ),
    );
  }
}