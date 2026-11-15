import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vanep_mobile/core/domain/postal_address_draft.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/entities/brazilian_city.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/entities/brazilian_state.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/failures/cep_failure.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/failures/ibge_locations_failure.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/usecases/list_cities.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/usecases/list_states.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/usecases/lookup_cep.dart';

class PostalAddressEdit {
  const PostalAddressEdit({
    this.address,
    this.isLookingUpCep,
    this.cepFailure,
    this.clearCepFailure = false,
    this.catalogStates,
    this.catalogCities,
    this.catalogFailure,
    this.clearCatalogFailure = false,
  });
  final PostalAddressDraft? address;
  final bool? isLookingUpCep;
  final CepFailure? cepFailure;
  final bool clearCepFailure;
  final List<BrazilianState>? catalogStates;
  final List<BrazilianCity>? catalogCities;
  final IbgeLocationsFailure? catalogFailure;
  final bool clearCatalogFailure;
}

mixin PostalAddressEditor<S> on Cubit<S> {
  PostalAddressDraft get editorAddress;
  CepFailure? get editorCepFailure;
  LookupCep get addressLookupCep;
  ListStates get addressListStates;
  ListCities get addressListCities;
  Duration get cepLookupDebounce;
  void emitAddressEdit(PostalAddressEdit edit);

  Timer? cepLookupTimer;
  int cepLookupGeneration = 0;
  int cityListGeneration = 0;

  void cancelAddressLookup() {
    cepLookupTimer?.cancel();
    cepLookupGeneration++;
    cityListGeneration++;
  }

  void updateZipCode(String value) {
    cancelAddressLookup();
    final address = editorAddress.withZipCode(value);
    final willLookUp = address.zipCode.length == brazilianZipDigitCount;
    emitAddressEdit(
      PostalAddressEdit(
        address: address,
        clearCepFailure: true,
        isLookingUpCep: willLookUp,
      ),
    );
    if (!willLookUp) return;
    final generation = cepLookupGeneration;
    cepLookupTimer = Timer(cepLookupDebounce, () {
      if (!isClosed && generation == cepLookupGeneration) lookupDraftCep();
    });
  }

  void emitAddress(PostalAddressDraft address) =>
      emitAddressEdit(PostalAddressEdit(address: address));

  void updateStreet(String value) => emitAddressEdit(
    PostalAddressEdit(address: editorAddress.withStreet(value)),
  );
  void updateNumber(String value) => emitAddressEdit(
    PostalAddressEdit(address: editorAddress.withNumber(value)),
  );
  void updateComplement(String value) => emitAddressEdit(
    PostalAddressEdit(address: editorAddress.withComplement(value)),
  );
  void updateNeighborhood(String value) {
    if (editorAddress.isNeighborhoodLocked) return;
    emitAddressEdit(
      PostalAddressEdit(address: editorAddress.withNeighborhood(value)),
    );
  }

  Future<void> lookupDraftCep() async {
    final cep = editorAddress.zipCode;
    if (cep.length != brazilianZipDigitCount) return;
    final generation = cepLookupGeneration;
    final result = await addressLookupCep(cep);
    if (isClosed || generation != cepLookupGeneration) return;
    switch (result) {
      case Ok(:final value):
        cityListGeneration++;
        emitAddressEdit(
          PostalAddressEdit(
            address: editorAddress.withCepLookup(
              cityToken: value.cityToken,
              cityName: value.cityName,
              uf: value.uf,
              street: value.street,
              neighborhood: value.neighborhood,
            ),
            isLookingUpCep: false,
            clearCepFailure: true,
          ),
        );
      case Err(:final error):
        await applyCepLookupFailure(error);
    }
  }

  Future<void> applyCepLookupFailure(CepFailure failure) async {
    if (failure == CepFailure.invalidFormat) {
      emitAddressEdit(
        PostalAddressEdit(cepFailure: failure, isLookingUpCep: false),
      );
      return;
    }
    emitAddressEdit(
      PostalAddressEdit(
        address: failure.blocksSave
            ? editorAddress.withCepUnknown()
            : editorAddress.withCepUnavailable(),
        cepFailure: failure,
        isLookingUpCep: false,
      ),
    );
    await refreshStates();
  }

  Future<void> refreshStates() async {
    final result = await addressListStates();
    if (isClosed) return;
    emitAddressEdit(switch (result) {
      Ok(:final value) => PostalAddressEdit(
        catalogStates: value.items,
        clearCatalogFailure: true,
      ),
      Err(:final error) => PostalAddressEdit(catalogFailure: error),
    });
  }

  Future<void> selectUf(String uf) async {
    if (editorAddress.isCityLocked) return;
    emitAddressEdit(
      PostalAddressEdit(
        address: editorAddress.withUf(uf),
        catalogCities: const [],
        clearCepFailure: !(editorCepFailure?.blocksSave ?? false),
        clearCatalogFailure: true,
      ),
    );
    await refreshCities(uf);
  }

  Future<void> refreshCities(String uf, {String? search}) async {
    if (uf.isEmpty) return;
    final generation = ++cityListGeneration;
    final result = search == null || search.isEmpty
        ? await addressListCities(uf: uf)
        : await addressListCities(uf: uf, search: search);
    if (isClosed || generation != cityListGeneration) return;
    emitAddressEdit(switch (result) {
      Ok(:final value) => PostalAddressEdit(
        catalogCities: value.items,
        clearCatalogFailure: true,
      ),
      Err(:final error) => PostalAddressEdit(catalogFailure: error),
    });
  }

  void selectCity(BrazilianCity city) {
    if (editorAddress.isCityLocked) return;
    emitAddressEdit(
      PostalAddressEdit(
        address: editorAddress.withCity(
          token: city.token,
          name: city.name,
          uf: city.stateUf,
        ),
        clearCepFailure: !(editorCepFailure?.blocksSave ?? false),
      ),
    );
  }

  @override
  Future<void> close() {
    cancelAddressLookup();
    return super.close();
  }
}
