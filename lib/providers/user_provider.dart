import 'package:flutter/material.dart';
import 'package:homebazaar/core/provider_state.dart';
import 'package:homebazaar/model/misc.dart';
import 'package:homebazaar/model/property.dart';
import 'package:homebazaar/model/user.dart';
import 'package:homebazaar/services/users_service.dart';

class UserProvider extends ChangeNotifier {
  final _listings = ProviderState<List<ApiProperty>>();
  bool _updating = false;
  String? _updateError;

  List<ApiProperty> get myListings => _listings.data ?? [];
  bool get listingsLoading => _listings.loading;
  String? get listingsError => _listings.error;

  bool get updating => _updating;
  String? get updateError => _updateError;

  Future<void> fetchMyListings({
    PropertyStatus? status,
    int? page,
    int? limit,
  }) async {
    if (!_listings.shouldFetch) return;
    _listings.startLoading();
    notifyListeners();
    try {
      final res = await UsersService.myListings(
          status: status, page: page, limit: limit);
      _listings.setData(res.data);
    } catch (e) {
      _listings.setError(e.toString());
    }
    notifyListeners();
  }

  void invalidateListings() => _listings.clear();

  Future<ApiUser?> updateProfile({
    String? firstName, String? lastName, String? avatar,
    String? email, String? phone, String? panNumber,
    String? panCardImage, String? aadharNumber, String? aadharCardImage,
  }) async {
    _updating = true;
    _updateError = null;
    notifyListeners();
    try {
      final res = await UsersService.updateProfile(
        firstName: firstName, lastName: lastName, avatar: avatar,
        email: email, phone: phone, panNumber: panNumber,
        panCardImage: panCardImage, aadharNumber: aadharNumber,
        aadharCardImage: aadharCardImage,
      );
      _updating = false;
      notifyListeners();
      return ApiUser.fromJson(res.data['user'] as Map<String, dynamic>);
    } catch (e) {
      _updateError = e.toString();
      _updating = false;
      notifyListeners();
      return null;
    }
  }

  Future<UploadLinkResponse?> getUploadUrl(UploadFolder folder) async {
    try {
      final res = await UsersService.getUploadUrl(folder);
      return res.data;
    } catch (_) {
      return null;
    }
  }

  Future<bool> uploadFile({
    required Uri uploadUrl,
    required List<int> fileBytes,
    required String contentType,
  }) async {
    try {
      await UsersService.uploadToSupabase(
        uploadUrl: uploadUrl,
        fileBytes: fileBytes,
        contentType: contentType,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  void clear() {
    _listings.clear();
    notifyListeners();
  }
}
