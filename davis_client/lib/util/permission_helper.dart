import 'package:davis_client/models/app_permission.dart';
import 'package:davis_client/providers/permissions_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _container = ProviderContainer();

Future<bool> isPermissionGranted(AppPermission permission) async {
  final permissionsNotifier = _container.read(
    permissionsStateProvider.notifier,
  );
  return await permissionsNotifier.isPermissionGranted(permission);
}
