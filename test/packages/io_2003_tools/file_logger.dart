library file_logger;
import 'dart:isolate';
import 'dart:io';
import 'server_utils.dart';

startLogging() {
  print('started logger');
  File logFile;
  IOSink out;
  port.receive((msg, replyTo) {
    if (logFile == null) {
      print("Opening file $msg");
      logFile = new File(msg);
      out = logFile.openWrite(mode: FileMode.APPEND);
    } else {
      time('write to file', () {
        out.write("${new DateTime.now()} : $msg\n");
      });
    }
  });
}

SendPort _loggingPort;

void log(String message) {
  _loggingPort.send(message);
}

void initLogging(String logFileName) {
  _loggingPort = spawnFunction(startLogging);
  _loggingPort.send(logFileName);
}