import 'dart:async';
import 'dart:io';

import 'package:tesla/tesla.dart' show TeslaApiEndpoints;

class TeslaProxy {
  TeslaProxy(this.client, this.endpoints);

  final HttpClient client;
  final TeslaApiEndpoints endpoints;

  Future proxyServerRequest(HttpRequest serverRequest, Uri endpointUrl) async {
    final Uri uri = serverRequest.uri.replace(
        scheme: _schemeToHttp(endpointUrl.scheme),
        host: endpointUrl.host,
        port: endpointUrl.port);

    var serverResponse = serverRequest.response;
    var clientRequest = await client.openUrl(serverRequest.method, uri);
    clientRequest.headers.clear();
    serverRequest.headers.forEach((String key, List<String> values) {
      if (key == "host") {
        return;
      }

      clientRequest.headers.removeAll(key);

      for (String value in values) {
        clientRequest.headers.add(key, value);
      }
    });
    clientRequest.headers.contentType = serverRequest.headers.contentType;
    clientRequest.persistentConnection = serverRequest.persistentConnection;
    clientRequest.headers.chunkedTransferEncoding =
        serverRequest.headers.chunkedTransferEncoding;
    clientRequest.bufferOutput = false;
    clientRequest.followRedirects = false;
    clientRequest.cookies.clear();
    clientRequest.cookies.addAll(serverRequest.cookies);

    await serverRequest.listen((data) {
      clientRequest.add(data);
    }).asFuture();

    var clientResponse = await clientRequest.close();
    serverResponse.headers.clear();
    clientResponse.headers.forEach((String key, List<String> values) {
      serverResponse.headers.removeAll(key);
      for (String value in values) {
        serverResponse.headers.add(key, value);
      }
    });

    serverResponse.persistentConnection = clientResponse.persistentConnection;
    serverResponse.deadline = null;
    serverResponse.bufferOutput = false;
    serverResponse.statusCode = clientResponse.statusCode;
    serverResponse.reasonPhrase = clientResponse.reasonPhrase;
    serverResponse.contentLength = clientResponse.contentLength;
    serverResponse.headers.contentType = clientResponse.headers.contentType;

    await clientResponse.listen((data) {
      serverResponse.add(data);
    }).asFuture();

    if (clientResponse.statusCode == 101) {
      var clientSocket = await clientResponse.detachSocket();
      var serverSocket = await serverResponse.detachSocket();

      serverResponse.encoding = clientSocket.encoding;

      var clientToServerFuture = clientSocket.listen((data) {
        serverSocket.add(data);
      }).asFuture();

      var serverToClientFuture = serverSocket.listen((data) {
        clientSocket.add(data);
      }).asFuture();

      clientSocket.done.then((_) {
        serverSocket.close();
      });

      serverSocket.done.then((_) {
        clientSocket.close();
      });

      await Future.wait([clientToServerFuture, serverToClientFuture]);
    } else {
      await serverResponse.close();
    }
  }

  static String _schemeToHttp(String scheme) =>
      scheme == "wss" || scheme == "https" ? "https" : "http";
}

Future main(List<String> args) async {
  var address = args[0];
  var port = int.parse(args[1]);
  var server = await HttpServer.bind(address, port);
  var client = new HttpClient();
  var proxy = new TeslaProxy(client, new TeslaApiEndpoints.standard());

  client.autoUncompress = false;
  server.autoCompress = false;
  server.listen((request) async {
    request.response.headers.set("Access-Control-Allow-Origin", "*");
    request.response.headers.set("Access-Control-Allow-Headers", "*");

    if (request.method == "OPTIONS") {
      request.response.statusCode = 200;
      request.response.close();
      return;
    }

    var baseUri = Uri.parse(proxy.endpoints.ownersApiUrl.origin);
    var teslaType = request.uri.queryParameters["__tesla"];
    if (teslaType == "summon") {
      baseUri = Uri.parse(proxy.endpoints.summonConnectUrl.origin);
    }

    await proxy.proxyServerRequest(request, baseUri);
  });
}
