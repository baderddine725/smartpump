class AppConstants {
  static const String appName = 'smartpump';
  static const String appVersion = '1.0.0';
  
  // Configuration API
  static const String baseUrl = 'https://api.solar-pump-monitoring.com';
  static const int apiTimeout = 30000;
  
  // Configuration Modbus
  static const int modbusBaudRate = 9600;
  static const int modbusTimeout = 5000;
  
  // Stockage local
  static const String hiveBoxName = 'solar_pump_app';
  
  // Routes
  static const String initialRoute = '/splash';
}

class UserRoles {
  static const String farmer = 'farmer';
  static const String technician = 'technician';
  static const String entrepreneur = 'entrepreneur';
}

class PumpStatusConstants {
  static const String running = 'running';
  static const String stopped = 'stopped';
  static const String error = 'error';
  static const String maintenance = 'maintenance';
}