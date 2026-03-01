class SmsGatewayModel {
  final String baseUrl;
  final String method;
  final String endpoint; // Manually set endpoint
  final List<Map<String, String>> headers;
  final List<Map<String, String>> body;
  final List<Map<String, String>> params;
  final String textFormatData;

  SmsGatewayModel({
    required this.baseUrl,
    required this.method,
    required this.endpoint, // Manually set
    required this.headers,
    required this.body,
    required this.params,
    required this.textFormatData,
  });

  factory SmsGatewayModel.fromJson(Map<String, dynamic> json, {String? endpoint}) {
    return SmsGatewayModel(
      baseUrl: json['base_url'] ?? '',
      method: json['sms_gateway_method'] ?? 'POST',
      endpoint: json['variable'] ?? '', // Set manually or use default
      headers: _parseList(json, 'header_key', 'header_value'),
      body: _parseList(json, 'body_key', 'body_value'),
      params: _parseList(json, 'params_key', 'params_value'),
      textFormatData: json['text_format_data'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'base_url': baseUrl,
      'sms_gateway_method': method,
      'headers': headers,
      'body': body,
      'params': params,
      'text_format_data': textFormatData,
      'variable':endpoint
    };
  }

  static List<Map<String, String>> _parseList(Map<String, dynamic> json, String keyKey, String valueKey) {
    if (json.containsKey(keyKey) && json.containsKey(valueKey)) {
      List keys = json[keyKey] ?? [];
      List values = json[valueKey] ?? [];
      return List.generate(keys.length, (index) {
        return {
          keys[index].toString(): index < values.length ? values[index].toString() : '',
        };
      });
    }
    return [];
  }
}
