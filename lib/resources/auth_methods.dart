import 'dart:developer';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instagram_clone/resources/storage_methods.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //sign up the user

  Future<String> signupUser({
    required String username,
    required String email,
    required String password,
    required String bio,
    required Uint8List file,
  }) async {
    String result = 'some error occured';

    try {
      log('try');
      if (username.isNotEmpty &&
          email.isNotEmpty &&
          password.isNotEmpty &&
          bio.isNotEmpty &&
          file != null) {
        //register the user with firebase
        log('body of try');
        UserCredential credential = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);

        String photoUrl = await StorageMethods()
            .uploadImageToStorage('profilePics', file, false);

        //user to database firestore

        await _firestore.collection('users').doc(credential.user!.uid).set({
          'username': username,
          'uid': credential.user!.uid,
          'email': email,
          'bio': bio,
          'photoUrl': photoUrl,
          'followers': [],
          'following': [],
        });

        result = 'success';
      }
    } on FirebaseAuthException catch (err) {
      if (err.code == 'invalid-email') {
        result = 'email badly formatted';
      } else if (err.code == 'weak-password') {
        result = 'password should be atleast 6 characters';
      }
    } catch (err) {
      result = err.toString();
      log(result);
    }

    return result;
  }

  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String result = 'some error occured';

    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        result = 'success';
      } else {
        result = 'please enter all the fields';
      }
    } catch (e) {
      result = e.toString();
    }
    return result;
  }
}
