import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:usaficity/data/models/blog.dart';
import 'package:usaficity/data/models/starblog.dart';

import '../models/feedback.dart';
import '../models/location.dart';
import '../models/signalisation.dart';

class DBServices {
  CollectionReference usersDB = FirebaseFirestore.instance.collection('users');
  CollectionReference blogDB = FirebaseFirestore.instance.collection('blogs');
  CollectionReference starBlogDB =
      FirebaseFirestore.instance.collection('starBlogs');
  CollectionReference signalDB =
      FirebaseFirestore.instance.collection('signalisations');
  CollectionReference phoneFeedbacks = FirebaseFirestore.instance.collection(
    'phoneFeedbacks',
  );
  FirebaseStorage storage = FirebaseStorage.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Stream<User?> get user => auth.authStateChanges();

  GoogleSignIn googleSignIn = GoogleSignIn();

  signInWithGoogle() async {
    // Trigger the authentication flow
    GoogleSignInAccount? googleUser = await (googleSignIn.signIn());

    if (googleUser == null) {
      return null;
    }

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  signOut() async {
    await googleSignIn.signOut();
    await auth.signOut();
  }

  uploadSignalisationFile(file) async {
    Reference reference = storage.ref().child(
          'signalisations/${DateTime.now()}',
        );
    UploadTask uploadTask = reference.putFile(file);
    TaskSnapshot taskSnapshot = await uploadTask;
    return await taskSnapshot.ref.getDownloadURL();
  }

  addSignalisation(SignalModel signalModel) {
    signalDB.add({
      "name": signalModel.name,
      "email": signalModel.email,
      "imgUrl": signalModel.img,
      "content": signalModel.content,
      "location": {
        "lat": signalModel.location.lat,
        "lng": signalModel.location.lng,
      },
      "time": FieldValue.serverTimestamp(),
    });
  }

  uploadBlogFile(file) async {
    Reference reference = storage.ref().child(
          'blogs/${DateTime.now()}',
        );
    UploadTask uploadTask = reference.putFile(file);
    TaskSnapshot taskSnapshot = await uploadTask;
    return await taskSnapshot.ref.getDownloadURL();
  }

  addBlog(BlogModel blogModel) {
    blogDB.add({
      "authorName": blogModel.authorName,
      "authorEmail": blogModel.authorName,
      "authorImg": blogModel.authorImg,
      "imgUrl": blogModel.img,
      "content": blogModel.content,
      "time": FieldValue.serverTimestamp(),
    });
  }

  addFeedBack(FeedBack feedBack) {
    phoneFeedbacks.add({
      "userName": feedBack.name,
      "userMail": feedBack.email,
      "content": feedBack.content,
      "userPhone": feedBack.type,
      "time": FieldValue.serverTimestamp(),
    });
  }

  addUserLocation(UserLoc userLoc) {
    usersDB.add({
      "name": userLoc.name,
      "email": userLoc.email,
      "location": {
        "lat": userLoc.location.lat,
        "lng": userLoc.location.lng,
      },
      "time": FieldValue.serverTimestamp(),
    });
  }

  addStarBlog(StarBlogModel starBlogModel) {
    starBlogDB.add({
      "userName": starBlogModel.userName,
      "userMail": starBlogModel.userMail,
      "authorName": starBlogModel.authorName,
      "authorMail": starBlogModel.authorMail,
      "blogTitle": starBlogModel.blogTitle,
      "isStar": starBlogModel.star.isStar,
      "starCount": starBlogModel.star.starNumber,
      "time": FieldValue.serverTimestamp(),
    });
  }

  rmvUserLocation(dynamic userID) => usersDB.doc(userID).delete();

  updateUserLocation(String userID, Location location) async {
    try {
      await usersDB.doc(userID).update({
        'location': {
          'lat': location.lat,
          'lng': location.lng,
        },
      });
    } on FirebaseException catch (e) {
      print('Ann error due to firebase occured $e');
    } catch (err) {
      print('Ann error occured $err');
    }
  }
}
