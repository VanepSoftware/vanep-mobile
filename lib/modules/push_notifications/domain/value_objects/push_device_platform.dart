enum PushDevicePlatform {
  android('ANDROID'),
  ios('IOS');

  const PushDevicePlatform(this.apiName);

  final String apiName;
}
