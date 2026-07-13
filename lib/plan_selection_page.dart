import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PlanSelectionPage extends StatelessWidget {
  final bool isCurrentPremium;
  const PlanSelectionPage({Key? key, required this.isCurrentPremium}) : super(key: key);

  // ✅ Stripeの本番支払いリンク
  static const String paymentUrl = "https://buy.stripe.com/4gMcN608agD26fpeFz1Nu01"; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Select Plan / プラン選択", 
          style: TextStyle(color: Color(0xFF1B263B), fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1B263B)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
        child: Column(
          children: [
            const Text("Upgrade your Teamwork", 
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1B263B))),
            const SizedBox(height: 8),
            const Text("自発的な貢献を加速させる。", style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 40),
            
            // --- Free Plan (無料プラン) ---
            _buildPlanCard(
              context,
              title: "Free",
              japaneseTitle: "無料プラン",
              price: "\$0",
              subPrice: "forever / ずっと無料",
              features: [
                "Use Task Box / タスクボックスの利用",
                "3 Basic Attributes (Quick/Normal/Important) / 基本の3属性",
                "Share with up to 3 members / 共有メンバー 3名まで",
              ],
              buttonText: isCurrentPremium ? "Basic Access" : "Current Plan",
              buttonSubText: isCurrentPremium ? "ベーシックアクセス" : "現在のプラン",
              isRecommended: false,
              onPressed: null,
            ),

            const SizedBox(height: 24),

            // --- Premium Plan (プレミアムプラン) ---
            _buildPlanCard(
              context,
              title: "Premium",
              japaneseTitle: "プレミアムプラン",
              price: "\$10",
              subPrice: "/ month (月額)",
              features: [
                "All features unlocked / 全ての機能が使い放題",
                "Unlimited shared members / 共有メンバー 無制限",
                "Full history storage / 貢献履歴の全期間保存",
                "Advanced gamification settings / 高度な設定",
                "Priority Support / 優先サポート",
              ],
              buttonText: isCurrentPremium ? "Active Now" : "Upgrade to Premium",
              buttonSubText: isCurrentPremium ? "プレミアム利用中" : "プレミアムにアップグレード",
              isRecommended: true,
              onPressed: isCurrentPremium ? null : () => _launchStripe(context),
            ),

            const SizedBox(height: 32),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Maybe Later (後で決める)", style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context, {
    required String title,
    required String japaneseTitle,
    required String price,
    required String subPrice,
    required List<String> features,
    required String buttonText,
    required String buttonSubText,
    required bool isRecommended,
    VoidCallback? onPressed,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isRecommended ? const Color(0xFF1B263B) : Colors.transparent, 
          width: 2
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isRecommended ? 0.1 : 0.05), 
            blurRadius: 20, 
            offset: const Offset(0, 10)
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isRecommended)
            Align(
              alignment: Alignment.topRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B263B), 
                  borderRadius: BorderRadius.circular(12)
                ),
                child: const Text("RECOMMENDED", 
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ),
          Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1B263B))),
          Text(japaneseTitle, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(price, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF1B263B))),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(subPrice, style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
              ),
            ],
          ),
          const Divider(height: 40),
          ...features.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Color(0xFF1B263B), size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text(f, style: const TextStyle(fontSize: 14, color: Color(0xFF415A77)))),
              ],
            ),
          )),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: isRecommended ? const Color(0xFF1B263B) : Colors.grey.shade200,
                foregroundColor: isRecommended ? Colors.white : Colors.grey.shade700,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(buttonText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text(buttonSubText, style: const TextStyle(fontSize: 10)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🌟 Stripe決済へのジャンプ（機能維持）
  Future<void> _launchStripe(BuildContext context) async {
    final User? user = FirebaseAuth.instance.currentUser;
    final String? uid = user?.uid;
    final String? email = user?.email;

    if (uid == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("ログイン情報が見つかりません。再ログインしてください。")),
        );
      }
      return;
    }

    final String checkoutUrl = "$paymentUrl?client_reference_id=$uid&prefilled_email=${email ?? ""}";
    final Uri url = Uri.parse(checkoutUrl);

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("決済ページを開けませんでした: $e")),
        );
      }
    }
  }
}