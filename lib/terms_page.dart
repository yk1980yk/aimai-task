import 'package:flutter/material.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Terms / 利用規約",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("marcheZ Terms of Service / 利用規約"),
            const Text(
              "Ark Inc. (the 'Company') establishes the following terms for the task management platform 'marcheZ' ('Service').",
              style: TextStyle(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.bold),
            ),
            const Text(
              "株式会社Ark（以下「当社」）が提供するタスク管理プラットフォーム「marcheZ」（以下「本サービス」）の利用に関し、以下の通り規約を定めます。",
              style: TextStyle(fontSize: 12, color: Colors.black38),
            ),

            _buildSubsection("Article 1 (General Rules) / 第1条（総則）"),
            _buildBodyText(
              "1. These terms apply to all users of the Service. / 本規約は、本サービスを利用する全てのユーザーに適用されます。[cite: 15]\n\n"
              "2. 'Tasks' refer to any activity indicators entered on the Service. / 「タスク」とは、ユーザーが本サービス上に入力するあらゆる活動指標を指します。[cite: 15]"
            ),

            _buildSubsection("Article 2 (Disclaimer) / 第2条（免責）"),
            _buildBodyText(
              "1. The Service provides a flexible interface to reduce psychological burden. / 本サービスは、心理的負担を軽減する「曖昧さ」を許容するインターフェースを提供します。[cite: 15]\n\n"
              "2. Progress on the Service does not guarantee real-world completion. / 本サービス上の進捗が実社会での業務完遂を保証するものではないことを承諾します。[cite: 15]"
            ),

            _buildSubsection("Article 3 (Prohibitions) / 第3条（禁止事項）"),
            _buildBodyText(
              "1. Impersonation or inappropriate content is prohibited. / なりすましや不適切な投稿を禁止します。[cite: 15]\n\n"
              "2. Security exploits are prohibited. / セキュリティの脆弱性を突く行為等を禁止します。[cite: 15]"
            ),

            _buildSubsection("Article 4 (Payments) / 第4条（有料プラン・決済）"),
            _buildBodyText(
              "1. Payments are via Stripe. No refunds for mid-period cancellations. / 決済はStripeを通じて行われ、期間途中の返金は行いません。[cite: 15]"
            ),

            _buildSubsection("Article 5 (Data) / 第5条（データ）"),
            _buildBodyText(
              "1. Ownership of created data belongs to the user. / 作成したデータの権利はユーザーに帰属します。[cite: 15]\n\n"
              "2. The Company is not liable for data loss due to unexpected accidents. / 予期せぬ事故によるデータ消失について、当社は法的責任を負いません。[cite: 15]"
            ),

            const Divider(height: 60),

            _buildSectionTitle("Privacy Policy / プライバシーポリシー"),
            _buildSubsection("Section 1 (Collection) / 第1項（収集）"),
            _buildBodyText(
              "We collect Name, Email, and Profile Picture via Google account. / Googleアカウント経由で、氏名、メールアドレス、写真等を取得します。[cite: 15]"
            ),

            _buildSubsection("Section 2 (Purpose) / 第2項（目的）"),
            _buildBodyText(
              "1. Improvement of UI/UX and maintenance. / 本サービスの提供、維持、改善。[cite: 15]\n\n"
              "2. Security and fraud prevention. / セキュリティ対策および不正利用の防止。[cite: 15]"
            ),

            _buildSubsection("Section 3 (Compliance) / 第3項（準拠）"),
            _buildBodyText(
              "The Service complies with Google Data Policies. / 本サービスはGoogleのデータポリシーを遵守します。[cite: 15]"
            ),

            const SizedBox(height: 50),

            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("Back / 戻る", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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