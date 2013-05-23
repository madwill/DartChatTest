library chatserver;

import 'dart:io';
import 'dart:isolate';
import 'dart:async';
import 'file-logger.dart' as log;
import 'server-utils.dart';

class StaticFileHandler {
  final String basePath;

  StaticFileHandler(this.basePath);

  _send404(HttpResponse response) {
    response.statusCode = HttpStatus.NOT_FOUND;
    response.close();
  }

  // TODO: etags, last-modified-since support
  onRequest(HttpRequest request) {
    final String path =
        request.uri.path == '/' ? '/index.html' : request.uri.path;
    final File file = new File('${basePath}${path}');
    file.exists().then((bool found) {
      if (found) {
        file.fullPath().then((String fullPath) {
          if (!fullPath.startsWith(basePath)) {
            _send404(request.response);
          } else {
            file.openRead().pipe(request.response)
              .catchError((e) => print(e));
          }
        });
      } else {
        _send404(request.response);
      }
    });
  }
}

class ChatHandler {
  Set<WebSocket> webSocketConnections = new Set<WebSocket>();

  ChatHandler(String basePath) {
    log.initLogging('${basePath}/chat-log.txt');
  }

  // closures!
  onConnection(WebSocket conn) {
    void onMessage(message) {
      print('new ws msg: $message');
      webSocketConnections.forEach((connection) {
        if (conn != connection) {
          print('queued msg to be sent');
          queue(() => connection.add(message));
        }
      });
      time('send to isolate', () => log.log(message));
    }
    
    print('new ws conn');
    webSocketConnections.add(conn);
    conn.listen(onMessage,
      onDone: () => webSocketConnections.remove(conn),
      onError: (e) => webSocketConnections.remove(conn)
    );
  }
}

runServer(String basePath, int port) {
  ChatHandler chatHandler = new ChatHandler(basePath);
  StaticFileHandler fileHandler = new StaticFileHandler(basePath);
  
  HttpServer.bind('127.0.0.1', port)
    .then((HttpServer server) {
      print('listening for connections on $port');
      
      var sc = new StreamController();
      sc.stream.transform(new WebSocketTransformer()).listen(chatHandler.onConnection);

      server.listen((HttpRequest request) {
        if (request.uri.path == '/ws') {
          sc.add(request);
        } else {
          fileHandler.onRequest(request);
        }
      });
    },
    onError: (error) => print("Error starting HTTP server: $error"));
}

main() {
  var script = new File(new Options().script);
  var directory = script.directorySync();
  runServer("${directory.path}/client", 1337);
}
