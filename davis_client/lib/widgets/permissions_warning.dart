import 'package:davis_client/providers/permissions_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PermissionsWarning extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissionsState = ref.watch(permissionsStateProvider);
    List<String> deniedPermissions = [];
    if (!permissionsState.camera) deniedPermissions.add("Camera");
    if (!permissionsState.microphone) deniedPermissions.add("Microphone");
    if (!permissionsState.location) deniedPermissions.add("Location");

    if (deniedPermissions.isEmpty) return SizedBox.shrink();

    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.warning, color: Colors.yellow, size: 30),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Permissions Denied",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "${deniedPermissions.join(', ')} needed",
                  style: TextStyle(color: Colors.white70),
                ),
                Text(
                  "Davis will be degraded.",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
