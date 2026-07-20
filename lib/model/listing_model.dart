import 'package:rentit24/config/api_config.dart';

class ListingModel {
  const ListingModel({
    this.id = 0,
    this.ownerId = 0,
    this.ownerName = '',
    this.ownerProfileUrl = '',
    this.listingType = '',
    this.title = '',
    this.description = '',
    this.categoryId = 0,
    this.categoryName = '',
    this.subcategoryId = 0,
    this.subcategoryName = '',
    this.rentalPrice = 0,
    this.priceUnit = '',
    this.securityDeposit = 0,
    this.brand = '',
    this.modelName = '',
    this.color = '',
    this.additionalDetails = '',
    this.profession = '',
    this.experience = '',
    this.skills = '',
    this.localAreaId = 0,
    this.address = '',
    this.latitude = 0,
    this.longitude = 0,
    this.status = '',
    this.rejectionReason = '',
    this.isFeatured = false,
    this.isTopChoice = false,
    this.isVerified = false,
    this.viewCount = 0,
    this.rating = 0,
    this.reviewCount = 0,
    this.imageUrl = '',
    this.distanceKm,
    this.postedAt,
    this.totalCount,
  });

  final int id;
  final int ownerId;
  final String ownerName;
  final String ownerProfileUrl;
  final String listingType;
  final String title;
  final String description;
  final int categoryId;
  final String categoryName;
  final int subcategoryId;
  final String subcategoryName;
  final double rentalPrice;
  final String priceUnit;
  final double securityDeposit;
  final String brand;
  final String modelName;
  final String color;
  final String additionalDetails;
  final String profession;
  final String experience;
  final String skills;
  final int localAreaId;
  final String address;
  final double latitude;
  final double longitude;
  final String status;
  final String rejectionReason;
  final bool isFeatured;
  final bool isTopChoice;
  final bool isVerified;
  final int viewCount;
  final double rating;
  final int reviewCount;
  final String imageUrl;
  final double? distanceKm;
  final DateTime? postedAt;
  final int? totalCount;

  bool get isService => listingType.toLowerCase() == 'service';
  String get displayPrice {
    final value = rentalPrice == rentalPrice.roundToDouble()
        ? rentalPrice.toStringAsFixed(0)
        : rentalPrice.toStringAsFixed(2);
    final unit = priceUnit.trim().isEmpty ? '' : '/$priceUnit';
    return '₹$value$unit';
  }

  factory ListingModel.fromJson(Map<String, dynamic> json) {
    return ListingModel(
      id: _toInt(_read(json, 'id')),
      ownerId: _toInt(_read(json, 'owner_id', 'ownerId')),
      ownerName: _toString(_read(json, 'owner_name', 'ownerName')),
      ownerProfileUrl: ApiConfig.resolveMediaUrl(
        _toString(_read(json, 'owner_profile_url', 'ownerProfileUrl', 'owner_photo')),
      ),
      listingType: _toString(_read(json, 'listing_type', 'listingType')),
      title: _toString(_read(json, 'title')),
      description: _toString(_read(json, 'description')),
      categoryId: _toInt(_read(json, 'category_id', 'categoryId')),
      categoryName: _toString(_read(json, 'category_name', 'categoryName')),
      subcategoryId: _toInt(_read(json, 'subcategory_id', 'subcategoryId')),
      subcategoryName: _toString(_read(json, 'subcategory_name', 'subcategoryName')),
      rentalPrice: _toDouble(_read(json, 'rental_price', 'rentalPrice')),
      priceUnit: _toString(_read(json, 'price_unit', 'priceUnit')),
      securityDeposit: _toDouble(_read(json, 'security_deposit', 'securityDeposit')),
      brand: _toString(_read(json, 'brand')),
      modelName: _toString(_read(json, 'model_name', 'modelName')),
      color: _toString(_read(json, 'color')),
      additionalDetails: _toString(_read(json, 'additional_details', 'additionalDetails')),
      profession: _toString(_read(json, 'profession')),
      experience: _toString(_read(json, 'experience')),
      skills: _toString(_read(json, 'skills')),
      localAreaId: _toInt(_read(json, 'local_area_id', 'localAreaId')),
      address: _toString(_read(json, 'address')),
      latitude: _toDouble(_read(json, 'latitude')),
      longitude: _toDouble(_read(json, 'longitude')),
      status: _toString(_read(json, 'status')),
      rejectionReason: _toString(_read(json, 'rejection_reason', 'rejectionReason')),
      isFeatured: _toBool(_read(json, 'is_featured', 'isFeatured')),
      isTopChoice: _toBool(_read(json, 'is_top_choice', 'isTopChoice')),
      isVerified: _toBool(_read(json, 'is_verified', 'isVerified')),
      viewCount: _toInt(_read(json, 'view_count', 'viewCount')),
      rating: _toDouble(_read(json, 'rating')),
      reviewCount: _toInt(_read(json, 'review_count', 'reviewCount')),
      imageUrl: ApiConfig.resolveMediaUrl(
        _toString(_read(json, 'image_url', 'imageUrl', 'listing_image')),
      ),
      distanceKm: _toNullableDouble(_read(json, 'distance_km', 'distanceKm')),
      postedAt: _toDate(_read(json, 'posted_at', 'postedAt')),
      totalCount: _toNullableInt(_read(json, 'total_count', 'totalCount')),
    );
  }

  Map<String, dynamic> toCreateJson() {
    final map = <String, dynamic>{
      'ownerId': ownerId,
      'listingType': listingType,
      'title': title,
      'description': description,
      'categoryId': categoryId,
      'subcategoryId': subcategoryId == 0 ? null : subcategoryId,
      'rentalPrice': rentalPrice,
      'priceUnit': priceUnit,
      'securityDeposit': securityDeposit == 0 ? null : securityDeposit,
      'brand': brand,
      'modelName': modelName,
      'color': color,
      'additionalDetails': additionalDetails,
      'profession': profession,
      'experience': experience,
      'skills': skills,
      'localAreaId': localAreaId == 0 ? null : localAreaId,
      'address': address,
      'latitude': latitude == 0 ? null : latitude,
      'longitude': longitude == 0 ? null : longitude,
    };
    map.removeWhere((key, value) => value == null || (value is String && value.trim().isEmpty));
    return map;
  }

  Map<String, dynamic> toUpdateJson() {
    final map = toCreateJson();
    map['id'] = id;
    map.remove('ownerId');
    map.remove('listingType');
    return map;
  }

  static dynamic _read(Map<String, dynamic> json, String first, [String? second, String? third]) {
    if (json.containsKey(first)) return json[first];
    if (second != null && json.containsKey(second)) return json[second];
    if (third != null && json.containsKey(third)) return json[third];
    return null;
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString().trim() ?? '') ?? 0;
  }

  static int? _toNullableInt(dynamic value) {
    if (value == null || value.toString().trim().isEmpty) return null;
    return _toInt(value);
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString().trim() ?? '') ?? 0;
  }

  static double? _toNullableDouble(dynamic value) {
    if (value == null || value.toString().trim().isEmpty) return null;
    return _toDouble(value);
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final text = value?.toString().trim().toLowerCase() ?? '';
    return text == 'true' || text == '1' || text == 'yes';
  }

  static String _toString(dynamic value) => value?.toString().trim() ?? '';

  static DateTime? _toDate(dynamic value) {
    final text = value?.toString().trim() ?? '';
    if (text.isEmpty) return null;
    return DateTime.tryParse(text);
  }
}
