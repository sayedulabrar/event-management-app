import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:get_it/get_it.dart';
import 'package:rive_flutter/service/local_notification.dart';
import 'auth_service.dart';

class PushNotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GetIt _getIt = GetIt.instance;

  late AuthService _authService;

  PushNotificationService() {
    _authService = _getIt.get<AuthService>();
  }

  Future<void> initialize() async {
    // Request permission for iOS
    // Request permissions for iOS

    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }

    // Get the token
    String? token = await _firebaseMessaging.getToken();
    print("FCM Token: $token");

    // Save the token to your database or send it to your server
    if (token != null) {
      await saveToken(token);
    } else {
      print("TOKEN NOT RECIVED.SADDDDDDDD");
    }

    // Listen for token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      print("FCM Token Refreshed: $newToken");
      await saveToken(newToken);
    }).onError((err) {
      print("Error getting token: $err");
    });
  }

  Future<void> saveToken(String token) async {
    // Save the token in Firestore with a generated document ID
    await _firestore.collection('tokens').add({
      'deviceToken': token,
    });
  }

  Future<List<String>> getAllTokens() async {
    QuerySnapshot snapshot = await _firestore.collection('tokens').get();
    Set<String> tokens = {};

    for (var doc in snapshot.docs) {
      if (doc['deviceToken'] != null) {
        tokens.add(doc['deviceToken']);
      }
    }

    return tokens.toList();
  }

  Future<String> getAccessToken() async {
    final serviceAccountJson = {
      "type": "service_account",
      "project_id": "rive-9f8c6",
      "private_key_id": "09be87c223e524b0ae348bc15e8ce42163b959fe",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC0px0rhXDKhPrO\n2dolgv10xqJRwUTqJQlUn30WtTJLTAlmYRjb1zr9aftBInoYPiMpg1Jp9yfae9+o\nDpbi1k+Tkl6+gojjCidrEhXjm/sLFXcploupqiqxVT3b8fuWKWXowxpFdTqA5o1O\nLtAdZcsugwmHglS9hjlQf4vp0aAQLOHl0wTuRFH1KBBD1h+93R/bQcAqG8dvwnwy\nlUDWUvPtTup0VFAzbfJ3ELLS1md8CxGVHosnqLHPX8IsuHfU9Y9GyPhHjo+Cikkp\n2e/iEtDZrwd1QgOOF+kJkLMlfvvyXQTr5bZ8MTJ6OqMBTGxrEUakEpf+F/2m+g/p\nLcRSVDezAgMBAAECggEAGGoRViVllekc4EGu6qzmRhbmLvhYsPAqb6ZSSHRahLSU\n/KIYsvVGgqMFEstvBsG3DNAzniCJ4UwmcNbv614dSQtaBJMtnslrhFvgW29kIR5Y\niWVQILDfrjGf946feq7DmA5uCX8LVgpShINtGtv79qA89HRXsXlnW4qxRPtQj37W\ntUIISo/m6WHbQVIKjccOFgoXbx/CvHW1cVHR5f1ESONtBVtbyIOBqCdEmyHNeXBj\nva31/qOajf03Of0Vliy0TvhR413fB8sBH6LSjNLITNBZDTQErkgu/m5K6cnb2GeT\nsl7G5v+IzYp4HMiix04ns4SIUXT+zfdxUqvdRoIrGQKBgQD1B1YH2AlPhvBCtXlx\nZBwHJNp0jQLxkY98qceXpyPo16s0o49JNYsysL4o+ehaaph3yZn2LtKSCXUMuJ8w\nC2jvrihWCMfYwUdVLpkJ9NXO1IOZwgcMn2r9mCflk1QsO1kiF3QdOGqdm3lYtuq6\nJlBej0PHHXHS8o/78rYnKEWdxQKBgQC8vd0Mckh+a04vVQmWKdfgZ8fDH8s7qQ+1\np94Dmb80/YrMQETkqGi94HuAf/s+FPLtjk75mOqrRitNZPG5OhAfCr//lZS6WUPZ\n+oDqGV1Y+WMZ1acRV3SMrc9QgJmyT+6yXCIE2c1Zye+/mnO+suhNVyKVZN/Z3LpV\nzVT1vkqPFwKBgQDyxEX0l5MB/EvnjC26rtkmKtlWSK/176YeeYiLNMpbU/MIwFSi\n0C4OFxcROimAC8TsSg4E3/c5Qa164SC3VVauwfqs4x4+H6ExQG3Yc3+y4NNSb+7U\nDs7OWwaMayAmgtaY9GvS16aqaPQddX2y2WsfhQo+KWow+qq1kY/v0/LFkQKBgF1S\nMz24NAft3pagoUDSJ58ZMThVPBOfn9jdy3RUTKpSwpIDJQ06B6/6kpYSsZMcoJC8\n0GexKDbPVxHJW4uOHfJ7SjuBJiyNfnME3UDikbkwdcOMVDLK3yG/vsW7EEOOKiOe\nUmO7nUFMC3LdV2Vu6FV1Q/BCFDyQWsGZ6Owozoy5AoGASjOkC+H0yRouEKl/ve6D\nPRLeXT93Szu61hPDIY5khCwZ9OcgoYHCmCmFApfqkViCaMKXEVu9y2b4sCthalmp\nxz6K11KPEPLjgJnNp/fwNO60r9WRy1ZE7HOXhOlUTmIkD8L/W5p2NPbO/QMOBdH8\nE8+WkhBGKqr1jbp/Pippk9I=\n-----END PRIVATE KEY-----\n",
      "client_email":
          "firebase-adminsdk-8wfil@rive-9f8c6.iam.gserviceaccount.com",
      "client_id": "106243648780988964772",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
          "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-8wfil%40rive-9f8c6.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };

    List<String> scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging",
    ];

    http.Client client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
    );

// get the access token
    auth.AccessCredentials credentials =
        await auth.obtainAccessCredentialsViaServiceAccount(
            auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
            scopes,
            client);

    client.close();

    return credentials.accessToken.data;
  }

  Future<void> sendNotification(
      String deviceToken, String title, String eventTime) async
  {
    final service = FlutterBackgroundService();
    final String serverAccessTokenkey = await getAccessToken();
    DateTime foradmin = DateTime.parse(eventTime);
    String endpointFirebaseCloudMessaging =
        'https://fcm.googleapis.com/v1/projects/rive-9f8c6/messages:send';

    final Map<String, dynamic> message = {
      "message": {
        "token": deviceToken,
        'notification': {"title": title, 'body': "New event added by admin"},
        'data': {'event_time': eventTime}
      }
    };

    final http.Response response = await http.post(
      Uri.parse(endpointFirebaseCloudMessaging),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serverAccessTokenkey',
      },
      body: jsonEncode(message),
    );

    if (response.statusCode == 200) {
      print('FCM message sent successfully');

      await GetIt.I<NotificationService>().showInstantNotification(
        title,
        "local notification"
      );
      // DateTime notificationTime = foradmin.subtract(Duration(minutes: 10));
      // if (notificationTime.isAfter(DateTime.now())) {
      //
      //   await GetIt.I<NotificationService>().scheduleNotification(
      //     0,
      //     title,
      //     "10 minutes remaining",
      //     notificationTime,
      //   );
      //
      // }
    } else {
      print('Failed to send FCM message: ${response.statusCode}');
      print(response.body);
    }
  }




}
