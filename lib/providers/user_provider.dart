import 'package:flutter/material.dart';
import 'package:homebazaar/model/misc.dart';
import 'package:homebazaar/model/property.dart';
import 'package:homebazaar/model/user.dart';
import 'package:homebazaar/services/users_service.dart';

class UserProvider extends ChangeNotifier {
  // ── Saved properties ──────────────────────────────────────────────────────
  List<ApiProperty> _saved = [];
  bool _savedLoading = false;
  String? _savedError;

  List<ApiProperty> get saved => _saved;
  bool get savedLoading => _savedLoading;
  String? get savedError => _savedError;

  // ── My listings ───────────────────────────────────────────────────────────
  List<ApiProperty> _myListings = [];
  bool _listingsLoading = false;
  String? _listingsError;

  List<ApiProperty> get myListings => _myListings;
  bool get listingsLoading => _listingsLoading;
  String? get listingsError => _listingsError;

  // ── Profile update ────────────────────────────────────────────────────────
  bool _updating = false;
  String? _updateError;

  bool get updating => _updating;
  String? get updateError => _updateError;

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> fetchSaved() async {
    _savedLoading = true;
    _savedError = null;
    notifyListeners();
    try {
      final res = await UsersService.saved();
      _saved = res.data;
    } catch (e) {
      _savedError = e.toString();
    }
    _savedLoading = false;
    notifyListeners();
  }

  Future<void> fetchMyListings({PropertyStatus? status, int? page, int? limit}) async {
    _listingsLoading = true;
    _listingsError = null;
    notifyListeners();
    try {
      final res = await UsersService.myListings(status: status, page: page, limit: limit);
      _myListings = res.data;
    } catch (e) {
      _listingsError = e.toString();
    }
    _listingsLoading = false;
    notifyListeners();
  }

  Future<ApiUser?> updateProfile({
    String? firstName,
    String? lastName,
    String? avatar,
    String? email,
    String? phone,
    String? panNumber,
    String? panCardImage,
    String? aadharNumber,
    String? aadharCardImage,
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
        uploadUrl: uploadUrl, fileBytes: fileBytes, contentType: contentType);
      return true;
    } catch (_) {
      return false;
    }
  }
}
