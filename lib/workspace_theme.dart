import 'package:flutter/material.dart';

/// ワークスペースの種類。Firestore の groups/{groupId}.type に保存する値。
class WorkspaceType {
  static const String family = 'family';
  static const String work = 'work';
}

/// Family / Work で見た目と文言だけを分岐させるためのテーマ定義。
/// タスクの保存構造（status/points/priority など）は共通のまま、
/// 表示レイヤーだけを出し分ける。
class WorkspaceTheme {
  final String type;

  // ブランドカラー
  final Color primary;
  final Color accent;
  final Color background;

  // BOX一覧でのアイコン
  final IconData boxIcon;

  // ボード上のデフォルトタイトル（BOX作成時にこの値をFirestoreへ保存）
  final String defaultSharedTitle;
  final String defaultDoneTitle;

  // クイックチュートリアルの文言
  final String tutorialHeader;
  final String step1Title;
  final String step1Desc;
  final String step2Title;
  final String step2Desc;
  final String step3Title;
  final String step3Desc;

  // 優先度（Quick/Normal/Important）の表示ラベル。
  // 保存される値（キー）は共通、表示だけ変える。
  final Map<String, String> priorityLabels;

  // ポイント表示の呼び方（例: "pt" / "がんばりポイント"）
  final String pointUnitShort; // カード上などの短い表記
  final String pointUnitLong; // チュートリアルなどの説明用

  // BOX選択カードの選択肢としての表示名
  final String selectorTitle;
  final String selectorSubtitle;
  final String selectorDescription;

  // ポイント節目達成時のお祝いポップアップのサブ文言
  final String milestoneSubtitle;

  const WorkspaceTheme({
    required this.type,
    required this.primary,
    required this.accent,
    required this.background,
    required this.boxIcon,
    required this.defaultSharedTitle,
    required this.defaultDoneTitle,
    required this.tutorialHeader,
    required this.step1Title,
    required this.step1Desc,
    required this.step2Title,
    required this.step2Desc,
    required this.step3Title,
    required this.step3Desc,
    required this.priorityLabels,
    required this.pointUnitShort,
    required this.pointUnitLong,
    required this.selectorTitle,
    required this.selectorSubtitle,
    required this.selectorDescription,
    required this.milestoneSubtitle,
  });

  static const WorkspaceTheme family = WorkspaceTheme(
    type: WorkspaceType.family,
    primary: Color(0xFFE8734A), // 温かみのあるオレンジ系
    accent: Color(0xFFFFB199),
    background: Color(0xFFFFF6F0),
    boxIcon: Icons.home_rounded,
    defaultSharedTitle: '🏠 Family Pool / お手伝いボックス',
    defaultDoneTitle: '✨ Reward Box / ごほうびボックス',
    tutorialHeader: 'How to play marcheZ 🚀 / かんたんガイド',
    step1Title: '1. DROP 🌊',
    step1Desc: "Put chores you'd love help with into the Family Pool\n(誰かにやってほしいお手伝いをここへ)",
    step2Title: '2. PICK 🤝',
    step2Desc: 'Grab a task when you have a free moment\n(手が空いた人が自分のフォルダへドラッグ)',
    step3Title: '3. EARN ✨',
    step3Desc: 'Finish it and points land in your Reward Box\n(完了すると「ごほうびボックス」にポイントが貯まる)',
    priorityLabels: {
      'Quick': 'Quick / ちょこっと',
      'Normal': 'Normal / ふつう',
      'Important': 'Important / がんばる',
    },
    pointUnitShort: 'pt',
    pointUnitLong: 'Effort Points / がんばりポイント',
    selectorTitle: 'Family',
    selectorSubtitle: '家族用',
    selectorDescription: "Turn 'please do it' into 'happy to help.'\n(「やってくれたら嬉しいな」を、みんなで叶え合う。)",
    milestoneSubtitle: "You're doing amazing!\n(よくがんばったね！)",
  );

  static const WorkspaceTheme work = WorkspaceTheme(
    type: WorkspaceType.work,
    primary: Color(0xFF1B263B), // 落ち着いたネイビー系（既存デザイン踏襲）
    accent: Color(0xFF415A77),
    background: Color(0xFFF0F4F8),
    boxIcon: Icons.business_center_rounded,
    defaultSharedTitle: '🌊 Shared Pool / タスクプール',
    defaultDoneTitle: '✅ Completed / 完了ボックス',
    tutorialHeader: 'How to play marcheZ 🚀 / クイックガイド',
    step1Title: '1. DROP 🌊',
    step1Desc: "Put unassigned tasks into the Shared Pool\n(誰の担当でもないタスクをここへ)",
    step2Title: '2. PICK 🤝',
    step2Desc: 'Drag tasks to your folder when you are free\n(手が空いた人が自分のフォルダへドラッグ)',
    step3Title: '3. WIN ✨',
    step3Desc: "Finish tasks to earn Contribution Points\n(完了すると貢献ポイントが貯まります)",
    priorityLabels: {
      'Quick': 'Quick / クイック',
      'Normal': 'Normal / 通常',
      'Important': 'Important / 重要',
    },
    pointUnitShort: 'pt',
    pointUnitLong: 'Contribution Points / 貢献ポイント',
    selectorTitle: 'Work',
    selectorSubtitle: '仕事用',
    selectorDescription: 'Stop the task tug-of-war. Make initiative visible.\n(タスクの押し付け合いをなくし、チームの自発性を可視化する。)',
    milestoneSubtitle: 'Great contribution to the team!\n(チームへの素晴らしい貢献です！)',
  );

  static WorkspaceTheme of(String? type) {
    if (type == WorkspaceType.family) return family;
    return work; // デフォルトは work（既存BOXとの後方互換のため）
  }

  static List<WorkspaceTheme> get all => [family, work];
}