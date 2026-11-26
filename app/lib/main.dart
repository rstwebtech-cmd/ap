import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

part 'core.dart';
part 'login_page.dart';
part 'signup_page.dart';
part 'home_page.dart';
part 'courses_page.dart';
part 'course_detail_page.dart';
part 'player_page.dart';
part 'quiz_page.dart';
part 'community_page.dart';
part 'profile_page.dart';

void main() => runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(colorSchemeSeed: const Color(0xFF6D28D9), scaffoldBackgroundColor: const Color(0xFFF5F3FF), useMaterial3: true),
    home: const LoginPage()));

