import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'app.dart';
import 'core/storage/secure_storage.dart';
import 'core/constants/app_constants.dart';
import 'features/widget/workmanager_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SecureStorageService().seedDevToken();

  await HomeWidget.setAppGroupId('com.sreyash.gitpulse');

  await registerWidgetRefresh();

  runApp(const ProviderScope(child: GitPulseApp()));
}
