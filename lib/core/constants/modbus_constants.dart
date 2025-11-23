class ModbusConstants {
  // Codes de fonctions Modbus
  static const int readMultipleRegisters = 0x03; // Lecture de plusieurs registres
  static const int writeSingleRegister = 0x06;   // Ecriture d’un registre
  static const int writeMultipleRegisters = 0x10; // Ecriture de plusieurs registres

  // Adresses de registres typiques pour variateur SAJ (à adapter selon modèle)
  static const int regVoltage = 0x0000;      // Tension
  static const int regCurrent = 0x0001;      // Courant
  static const int regPower = 0x0002;        // Puissance
  static const int regFrequency = 0x0003;    // Fréquence
  static const int regAlarm = 0x0010;        // Alarmes
  static const int regStartPump = 0x0100;    // Commande démarrage pompe
  static const int regStopPump = 0x0101;     // Commande arrêt pompe

  // Valeurs standard Modbus
  static const int slaveDefaultAddress = 1;
  static const int broadcastAddress = 0;

  // Timeout communication (en ms)
  static const int communicationTimeout = 5000;

  // CRC polynomial Modbus (utilisé en bas niveau si nécessaire)
  static const int crc16Polynomial = 0xA001;
}
