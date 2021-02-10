class Proxy {
  final String host;
  final String port;
  final String type;
  final String user;
  final String password;

  Proxy({this.host, this.port, this.type, this.user, this.password});

  factory Proxy.fromJson(Map<String, dynamic> json) {
    return Proxy(
        host: json['host'],
        port: json['port'],
        type: json['type'],
        user: json['user'],
        password: json['password']);
  }

  @override
  String toString() {
    return '{"host":"$host", "port":"$port", "type":"$type", "user":"$user", "password":"$password"}';
  }
}
