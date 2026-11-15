import 'package:vanep_mobile/core/domain/schedule/api_name.dart';

enum RouteLeg {
  outbound('OUTBOUND'),
  homebound('RETURN');

  const RouteLeg(this.apiName);

  final String apiName;

  static RouteLeg? fromApi(Object? raw) {
    return findByApiName(values, (value) => value.apiName, raw);
  }

  static String? toApi(RouteLeg? value) => value?.apiName;
}
