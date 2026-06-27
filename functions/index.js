const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.stripeWebhook = functions.https.onRequest(async (req, res) => {
  const event = req.body;

  // Stripeからの決済完了通知（checkout.session.completed）だけを処理する
  if (event.type === 'checkout.session.completed') {
    const session = event.data.object;
    const userId = session.client_reference_id; // Stripeに渡したUID

    if (userId) {
      try {
        // Firestoreの users コレクションにある該当ドキュメントを更新
        await admin.firestore().collection('users').doc(userId).set({
          isPremium: true,
          updatedAt: admin.firestore.FieldValue.serverTimestamp()
        }, { merge: true });
        
        console.log(`User ${userId} を有料会員に更新しました`);
      } catch (error) {
        console.error('Firestore更新エラー:', error);
      }
    } else {
      console.log('IDが含まれていない決済です');
    }
  }
  
  // Stripeに対して「受け取ったよ」と返事をする（これがないとStripeが何度も送ってくる）
  res.status(200).send('OK');
});