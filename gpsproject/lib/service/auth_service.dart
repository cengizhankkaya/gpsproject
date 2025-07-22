import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> registerUser(String email, String password, String name) async {
    try {
      // Firebase Authentication ile kullanıcı oluşturma
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Firestore'da kullanıcı bilgilerini saklama
      await _firestore.collection('Users').doc(userCredential.user?.uid).set({
        'name': name,
        'email': email,
        'location': "",
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Kullanıcı kaydı sırasında hata: $e');
    }
  }

  Future signInAnonymous() async {
    try {
      final result = await _auth.signInAnonymously();
      print(result.user!.uid);
      return result.user;
    } catch (e) {
      print("Anon error $e");
      return null;
    }
  }

  Future<String?> forgotPassword(String email) async {
    String? res;
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print("Mail kutunuzu kontrol ediniz");
    } on FirebaseAuthException catch (e) {
      if (e.code == "email-already-in-use") {
        res = "Mail Zaten Kayitli.";
      }
    }
    return res;
  }

  Future<String?> signIn(String email, String password) async {
    String? res;
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      res = "success";
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "user-not-found":
          res = "Kullanici Bulunamadi";
          break;
        case "wrong-password":
          res = "Hatali Sifre";
          break;
        case "user-disabled":
          res = "Kullanici Pasif";
          break;
        default:
          res = "Bir Hata Ile Karsilasildi, Birazdan Tekrar Deneyiniz.";
          break;
      }
    }
    return res;
  }

  Future<String?> signUp(
      String email, String username, String fullname, String password) async {
    String? res;
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await _firestore.collection("Users").doc(result.user?.uid).set({
        "email": email,
        "fullname": fullname,
        "username": username,
      });
      res = "success";
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "email-already-in-use":
          res = "Mail Zaten Kayitli.";
          break;
        case "ERROR_INVALID_EMAIL":
        case "invalid-email":
          res = "Gecersiz Mail";
          break;
        default:
          res = "Bir Hata Ile Karsilasildi, Birazdan Tekrar Deneyiniz.";
          break;
      }
    }
    return res;
  }

  Future<String> getUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userData =
            await _firestore.collection('Users').doc(user.uid).get();
        return userData.data().toString(); // Kullanıcı verilerini döndür
      } else {
        return "Kullanıcı oturumu açık değil";
      }
    } catch (e) {
      return "Hata: $e";
    }
  }
}
