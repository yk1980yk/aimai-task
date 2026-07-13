import 'package:flutter/material.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black),
          title: const Text(
            "Legal Information / リーガル情報",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          bottom: const TabBar(
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.black,
            tabs: [
              Tab(text: "Terms / 利用規約"),
              Tab(text: "Privacy / ポリシー"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildScrollableContent(_buildTermsContent()),
            _buildScrollableContent(_buildPrivacyContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollableContent(Widget content) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: content,
    );
  }

  // --- 利用規約 (marcheZ Bilingual Edition) ---
  Widget _buildTermsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("marcheZ Terms of Service / 利用規約"),
        _buildBodyText(
          "Ark Inc. (the 'Company') establishes the following terms for the task management platform 'marcheZ' ('Service').\n"
          "株式会社Ark（以下「当社」）が提供するタスク管理プラットフォーム「marcheZ」（以下「本サービス」）の利用に関し、以下の通り規約を定めます。"
        ),

        _buildSubsection("Article 1 (General Rules) / 第1条（総則）"),
        _buildBodyText(
          "1. These terms apply to all users of the Service. By using the Service, users agree to all clauses.\n"
          "1. 本規約は、本サービスを利用する全てのユーザーに適用されます。利用者は、本サービスを利用することで、本規約の全ての条項に同意したものとみなされます。\n\n"
          "2. 'Tasks' refer to any activity indicators or shared information entered on the Service.\n"
          "2. 「タスク」とは、ユーザーが本サービス上に入力するあらゆる活動指標および共有情報を指します。"
        ),

        _buildSubsection("Article 2 (Disclaimer) / 第2条（免責事項）"),
        _buildBodyText(
          "1. The Service provides a flexible interface to reduce psychological burden and encourage initiative.\n"
          "1. 本サービスは、心理的負担を軽減し、自発性を促すための柔軟なインターフェースを提供しますが、その正確性や実社会での成果を保証するものではありません。\n\n"
          "2. The Company is not liable for the actual completion of tasks in the real world.\n"
          "2. 当社は、本サービス上の進捗が実社会での業務完遂を保証するものではないことを明示し、ユーザーはこれを承諾するものとします。"
        ),

        _buildSubsection("Article 3 (Prohibitions) / 第3条（禁止事項）"),
        _buildBodyText(
          "1. Impersonation of others or posting inappropriate/offensive content is strictly prohibited.\n"
          "1. 他者へのなりすまし、または不適切・公序良俗に反する内容の投稿を禁止します。\n\n"
          "2. Any attempt to exploit security vulnerabilities is prohibited.\n"
          "2. 本サービスのセキュリティの脆弱性を突く行為、またはサーバーに過度な負荷をかける行為を禁止します。"
        ),

        _buildSubsection("Article 4 (Payment) / 第4条（有料プランおよび決済）"),
        _buildBodyText(
          "1. Payments for premium plans are processed via Stripe. Users must comply with Stripe's terms.\n"
          "1. 有料プランの決済はStripeを通じて行われ、ユーザーは当該プロバイダーの規約にも従うものとします。\n\n"
          "2. Subscriptions renew automatically at the end of each billing cycle unless cancelled beforehand. No refunds will be provided for the remainder of a billing period after cancellation.\n"
          "2. サブスクリプションは解約手続きが取られない限り、各請求サイクルの終了時に自動更新されます。デジタルコンテンツの特性上、決済完了後の利用期間途中におけるキャンセルおよび日割りでの返金には応じられません。"
        ),

        _buildSubsection("Article 5 (Data & Ownership) / 第5条（データと権利）"),
        _buildBodyText(
          "1. Ownership of the data created by the user belongs to the user.\n"
          "1. ユーザーが作成したデータの権利はユーザー自身に帰属します。\n\n"
          "2. The Company is not liable for any data loss caused by unexpected accidents or technical failures.\n"
          "2. 予期せぬ事故や技術的な障害によるデータ消失について、当社は一切の責任を負いません。"
        ),

        _buildSubsection("Article 6 (Eligibility & Minors) / 第6条（利用資格・未成年者の利用）"),
        _buildBodyText(
          "1. The Service is intended for use by individuals aged 13 or older. It is not directed at children under 13, and the Company does not knowingly collect personal information from them.\n"
          "1. 本サービスは13歳以上の方を対象としています。13歳未満の児童を対象としたものではなく、当社はそのような児童の個人情報を意図的に収集することはありません。\n\n"
          "2. Family-plan workspaces are intended to be created and administered by an adult (parent/guardian). Any use by a minor within a family workspace is the responsibility of the administering adult.\n"
          "2. 家族向けワークスペースは、保護者などの成人が作成・管理することを前提としています。家族ワークスペース内での未成年者の利用については、管理者である成人が責任を負うものとします。"
        ),

        _buildSubsection("Article 7 (Jurisdiction) / 第7条（準拠法・裁判管轄）"),
        _buildBodyText(
          "1. These terms are governed by the laws of Japan.\n"
          "1. 本規約の準拠法は日本法とします。\n\n"
          "2. Disputes shall be settled in the court having jurisdiction over the Company's headquarters.\n"
          "2. 本サービスに関する紛争は、当社の本店所在地を管轄する裁判所を専属的合意管轄とします。"
        ),
      ],
    );
  }

  // --- プライバシーポリシー (marcheZ Bilingual Edition) ---
  Widget _buildPrivacyContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Privacy Policy / プライバシーポリシー"),
        _buildBodyText(
          "Ark Inc. handles user personal information appropriately as follows.\n"
          "株式会社Arkは、ユーザーの個人情報を以下の通り適切に取り扱います。"
        ),

        _buildSubsection("1. Data Collection / 収集する情報"),
        _buildBodyText(
          "• Name, Email address, and Profile Picture through Google account authentication.\n"
          "• Payment history (processed by Stripe; the Company does not store card details).\n"
          "• Operation logs, device info, and IP addresses.\n"
          "・Googleアカウント経由の氏名、メールアドレス、プロフィール写真\n"
          "・決済履歴（Stripeが保持）、操作ログ、端末情報、IPアドレス"
        ),

        _buildSubsection("2. Purpose of Use / 利用目的"),
        _buildBodyText(
          "1. Providing, maintaining, and improving the Service UI/UX.\n"
          "2. Security and fraud prevention.\n"
          "3. Payment processing and management.\n"
          "1. 本サービスの提供、維持、およびUI/UXの改善\n"
          "2. セキュリティ対策および不正利用の防止\n"
          "3. 決済管理および本人確認"
        ),

        _buildSubsection("3. Third-party Provision / 第三者提供"),
        _buildBodyText(
          "We do not provide personal information to third parties without consent, except as required by law or for payment processing (Stripe).\n"
          "法令に基づく場合や決済処理を除き、同意なく第三者に個人情報を提供することはありません。"
        ),

        _buildSubsection("4. Data Protection / データの保護"),
        _buildBodyText(
          "All communications are encrypted with SSL/TLS. Access to databases is strictly restricted.\n"
          "全ての通信はSSL/TLSによって暗号化され、アクセスは厳重に制限されています。"
        ),

        _buildSubsection("5. Children's Privacy / 児童のプライバシー"),
        _buildBodyText(
          "The Service is not directed at children under 13, and we do not knowingly collect personal information from them. If we become aware that we have inadvertently collected such information, we will delete it promptly. Parents or guardians who believe their child has provided personal information may contact us using the address below.\n"
          "本サービスは13歳未満の児童を対象としたものではなく、当社は児童の個人情報を意図的に収集することはありません。誤って児童の個人情報を取得したことが判明した場合、速やかに削除します。お子様が個人情報を提供したと思われる場合は、下記連絡先までご連絡ください。"
        ),

        _buildSubsection("6. Rights of User / 開示・削除請求"),
        _buildBodyText(
          "Users may request data disclosure or deletion at any time. We will respond within a reasonable period.\n"
          "ユーザーは自身のデータの開示や削除をいつでも請求できます。当社は合理的な期間内にこれに対応します。"
        ),

        _buildSubsection("7. Contact / お問い合わせ窓口"),
        _buildBodyText(
          "For any questions regarding this Privacy Policy, please contact: info@ark-corp.tokyo\n"
          "本ポリシーに関するお問い合わせは info@ark-corp.tokyo までご連絡ください。"
        ),
      ],
    );
  }

  // --- 共通パーツ ---
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildSubsection(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1B263B))),
    );
  }

  Widget _buildBodyText(String text) {
    return Text(text, style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.6));
  }
}