import 'package:http/http.dart' as http;
import '../constants/modbus_constants.dart';

class ModbusService {
  final String deviceApiUrl; // URL du microcontrôleur exposant Modbus (REST ou websocket)

  ModbusService({required this.deviceApiUrl});

  /// Lecture de plusieurs registres Modbus
  Future<Map<String, dynamic>> readRegisters(int slave, int address, int qty) async {
    final response = await http.post(
      Uri.parse('$deviceApiUrl/read_registers'),
      body: {
        'slave': slave.toString(),
        'address': address.toString(),
        'quantity': qty.toString(),
      },
    );
    if (response.statusCode == 200) {
      return _parseRegisters(response.body);
    } else {
      throw Exception('Modbus readRegisters error: ${response.statusCode}');
    }
  }

  /// Ecriture sur un registre Modbus
  Future<bool> writeRegister(int slave, int address, int value) async {
    final response = await http.post(
      Uri.parse('$deviceApiUrl/write_register'),
      body: {
        'slave': slave.toString(),
        'address': address.toString(),
        'value': value.toString(),
      },
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Modbus writeRegister error: ${response.statusCode}');
    }
  }

  /// Analyse la réponse et extrait les valeurs
  Map<String, dynamic> _parseRegisters(String body) {
    // Adaptation selon le format (JSON, liste, etc.)
    // Ex: {"status": "OK", "registers": [123, 456, 789]}
    return {};
  }
}
