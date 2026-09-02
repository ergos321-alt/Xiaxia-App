import 'package:http/http.dart' as http;

import '../config/core_connection_config.dart';
import 'core_client.dart';
import 'http_core_client.dart';
import 'production_core_contract_adapter.dart';

class ProductionCoreClientFactory implements CoreClientFactory {
  const ProductionCoreClientFactory({this.httpClientFactory});

  final http.Client Function()? httpClientFactory;

  @override
  CoreClient create(CoreConnectionConfig config) {
    return HttpCoreClient(
      config: config,
      adapter: const ProductionCoreContractAdapter(),
      httpClient: httpClientFactory?.call(),
    );
  }
}
