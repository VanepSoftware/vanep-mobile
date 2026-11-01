import 'package:vanep_mobile/modules/negotiations/domain/value_objects/api_name.dart';

enum ServiceRequestStatus {
  open('OPEN'),
  answered('ANSWERED'),
  converted('CONVERTED'),
  declined('DECLINED'),
  expired('EXPIRED'),
  withdrawn('WITHDRAWN');

  const ServiceRequestStatus(this.apiName);

  final String apiName;

  static ServiceRequestStatus? fromApi(Object? raw) {
    return findByApiName(values, (value) => value.apiName, raw);
  }

  static String? toApi(ServiceRequestStatus? value) => value?.apiName;
}

const openServiceRequestStatuses = {
  ServiceRequestStatus.open,
  ServiceRequestStatus.answered,
};

const closedServiceRequestStatuses = {
  ServiceRequestStatus.converted,
  ServiceRequestStatus.declined,
  ServiceRequestStatus.expired,
  ServiceRequestStatus.withdrawn,
};
