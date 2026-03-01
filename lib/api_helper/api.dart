class ApiException implements Exception {
  String errorMessage;
  bool isNoInternet;

  ApiException(this.errorMessage, {this.isNoInternet = false});

  @override
  String toString() {
    return errorMessage;
  }
}