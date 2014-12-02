part of postgresql.impl;

class SettingsImpl implements Settings {
  String _host;
  int _port;
  String _user;
  String _password;
  String _database;
  bool _requireSsl;
  
  static const String DEFAULT_HOST = 'localhost';
  static const String HOST = 'host';
  static const String PORT = 'port';
  static const String USER = 'user';
  static const String PASSWORD = 'password';
  static const String DATABASE = 'database';
  
  SettingsImpl(this._host,
      this._port,
      this._user,
      this._password,
      this._database,
      {bool requireSsl: false})
    : _requireSsl = requireSsl;
  
  static _error(msg) => new PostgresqlException('Settings: $msg', null);
  
  factory SettingsImpl.fromUri(String uri) {
    
    var u = Uri.parse(uri);
    if (u.scheme != 'postgres' && u.scheme != 'postgresql')
      throw _error('Invalid uri.');

    if (u.userInfo == null || !u.userInfo.contains(':'))
      throw _error('Invalid uri.');

    var userInfo = u.userInfo.split(':');

    if (u.path == null || !u.path.startsWith('/'))
      throw _error('Invalid uri.');

    bool requireSsl = false;
    if (u.query != null)
      requireSsl = u.query.contains('sslmode=require');

    return new Settings(
        u.host,
        u.port == null ? Settings.defaultPort : u.port,
        userInfo[0],
        userInfo[1],
        u.path.substring(1, u.path.length), // Remove preceding forward slash.
        requireSsl: requireSsl);
  }

  SettingsImpl.fromMap(Map config){
    
    final String host = config.containsKey(HOST) ?
        config[HOST] : DEFAULT_HOST;
    final int port = config.containsKey(PORT) ?
        config[PORT] is int ? config[PORT]
          : throw _error('Specified port is not a valid number')
        : Settings.defaultPort;
    if (!config.containsKey(USER))
      throw _error(USER);
    if (!config.containsKey(PASSWORD))
      throw _error(PASSWORD);
    if (!config.containsKey(DATABASE))
      throw _error(DATABASE);
    
    this._host = config[HOST];
    this._port = port;
    this._user = config[USER];
    this._password = config[PASSWORD];
    this._database = config[DATABASE];

    this._requireSsl = config.containsKey('sslmode') 
        && config['sslmode'] == 'require';
  }
  
  String get host => _host;
  int get port => _port;
  String get user => _user;
  String get password => _password;
  String get database => _database;
  bool get requireSsl => _requireSsl;

  String toUri()
    => "postgres://$_user:$_password@$_host:$_port"
          "/$_database${requireSsl ? '?sslmode=require' : ''}";
  
  String toString()
    => "Settings {host: $_host, port: $_port, user: $_user, database: $_database}";

  Map toMap() {
    var map = new Map<String, dynamic>();
    map[HOST] = host;
    map[PORT] = port;
    map[USER] = user;
    map[PASSWORD] = password;
    map[DATABASE] = database;
    if (requireSsl)
      map['sslmode'] = 'require';
    return map;
  }
  
  Map toJson() => toMap();
}
