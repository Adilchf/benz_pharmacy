import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  static final firestore = FirebaseFirestore.instance;
  static final auth = FirebaseAuth.instance;
  static final storage = FirebaseStorage.instance;
}
