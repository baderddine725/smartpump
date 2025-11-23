class GetPumpStatus {
  final PumpRepository repository;

  GetPumpStatus(this.repository);

  Future<PumpStatus> execute(String pumpId) async {
    return await repository.getPumpStatus(pumpId);
  }
}