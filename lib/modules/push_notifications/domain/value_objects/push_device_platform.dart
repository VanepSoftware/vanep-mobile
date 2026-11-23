enum PushDevicePlatform {
  android('android'),
  ios('ios');

  const PushDevicePlatform(this.apiName);

  final String apiName;
}
