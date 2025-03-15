import 'dart:ffi';
// import 'dart:io';
// import 'dart:typed_data';
import 'package:ffi/ffi.dart';

// Load the C standard library
final DynamicLibrary libc = DynamicLibrary.open('libc.so.6');

// Define POSIX functions
final int Function(Pointer<Utf8>, int) open =
    libc
        .lookup<NativeFunction<Int32 Function(Pointer<Utf8>, Int32)>>('open')
        .asFunction();

final int Function(int, Pointer<Void>, int) read =
    libc
        .lookup<NativeFunction<Int32 Function(Int32, Pointer<Void>, Int32)>>(
          'read',
        )
        .asFunction();

final int Function(int) close =
    libc.lookup<NativeFunction<Int32 Function(Int32)>>('close').asFunction();

// Struct input_event is 24 bytes
const int inputEventSize = 24;

class LinuxInputEvent {
  final int type;
  final int code;
  final int value;

  LinuxInputEvent(this.type, this.code, this.value);

  @override
  String toString() => "Type: $type, Code: $code, Value: $value";
}

class InputDeviceReader {
  final String devicePath;
  bool _isReading = false;

  InputDeviceReader(this.devicePath);

  void startListening(Function(LinuxInputEvent event) onEvent) async {
    final deviceCStr = devicePath.toNativeUtf8();
    final fd = open(deviceCStr, 0); // O_RDONLY = 0
    calloc.free(deviceCStr);

    if (fd < 0) {
      print("Failed to open $devicePath");
      return;
    }

    _isReading = true;
    final buffer = calloc<Uint8>(inputEventSize);

    while (_isReading) {
      final bytesRead = read(fd, buffer.cast(), inputEventSize);
      if (bytesRead < inputEventSize) {
        print("Read error or end of file.");
        break;
      }

      // Parse the raw input_event struct
      final int type =
          buffer.elementAt(16).value | (buffer.elementAt(17).value << 8);
      final int code =
          buffer.elementAt(18).value | (buffer.elementAt(19).value << 8);
      final int value =
          buffer.elementAt(20).value | (buffer.elementAt(21).value << 8);

      // Create and send event
      final event = LinuxInputEvent(type, code, value);
      onEvent(event);
    }

    calloc.free(buffer);
    close(fd);
  }

  void stopListening() {
    _isReading = false;
  }
}
