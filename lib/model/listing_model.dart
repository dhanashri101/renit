import 'package:rentit24/core/utils/json_converters.dart';

class ListingModel {
  const ListingModel({
    this.id,
    this.ownerId,
    this.listingType,
    this.title,
    this.description,
    this.categoryId,
    this.subcategoryId,
    this.rentalPrice,
    this.priceUnit,
    this.securityDeposit,
    this.brand,
    this.modelName,
    this.color,
    this.additionalDetails,
    this.profession,
    this.experience,
    this.skills,
    this.localAreaId,
    this.address,
    this.latitude,
    this.longitude,
    this.status,
    this.rejectionReason,
    this.isFeatured,
    this.isTopChoice,
    this.isVerified,
    this.viewCount,
    this.rating,
    this.reviewCount,
    this.postedAt,
  });

  final int? id;
  final int? ownerId;
  final String? listingType;
  final String? title;
  final String? description;
  final int? categoryId;
  final int? subcategoryId;
  final double? rentalPrice;
  final String? priceUnit;
  final double? securityDeposit;
  final String? brand;
  final String? modelName;
  final String? color;
  final String? additionalDetails;
  final String? profession;
  final String? experience;
  final String? skills;
  final int? localAreaId;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? status;
  final String? rejectionReason;
  final bool? isFeatured;
  final bool? isTopChoice;
  final bool? isVerified;
  final int? viewCount;
  final double? rating;
  final int? reviewCount;
  final DateTime? postedAt;

  factory ListingModel.fromJson(Map<String, dynamic> json) {
    return ListingModel(
      id: JsonConverters.intValue(json['id']),
      ownerId: JsonConverters.intValue(json['ownerId'] ?? json['owner_id']),
      listingType: JsonConverters.stringValue(
        json['listingType'] ?? json['listing_type'],
      ),
      title: JsonConverters.stringValue(json['title']),
      description: JsonConverters.stringValue(json['description']),
      categoryId: JsonConverters.intValue(
        json['categoryId'] ?? json['category_id'],
      ),
      subcategoryId: JsonConverters.intValue(
        json['subcategoryId'] ?? json['subcategory_id'],
      ),
      rentalPrice: JsonConverters.doubleValue(
        json['rentalPrice'] ?? json['rental_price'],
      ),
      priceUnit: JsonConverters.stringValue(
        json['priceUnit'] ?? json['price_unit'],
      ),
      securityDeposit: JsonConverters.doubleValue(
        json['securityDeposit'] ?? json['security_deposit'],
      ),
      brand: JsonConverters.stringValue(json['brand']),
      modelName: JsonConverters.stringValue(
        json['modelName'] ?? json['model_name'],
      ),
      color: JsonConverters.stringValue(json['color']),
      additionalDetails: JsonConverters.stringValue(
        json['additionalDetails'] ?? json['additional_details'],
      ),
      profession: JsonConverters.stringValue(json['profession']),
      experience: JsonConverters.stringValue(json['experience']),
      skills: JsonConverters.stringValue(json['skills']),
      localAreaId: JsonConverters.intValue(
        json['localAreaId'] ?? json['local_area_id'],
      ),
      address: JsonConverters.stringValue(json['address']),
      latitude: JsonConverters.doubleValue(json['latitude']),
      longitude: JsonConverters.doubleValue(json['longitude']),
      status: JsonConverters.stringValue(json['status']),
      rejectionReason: JsonConverters.stringValue(
        json['rejectionReason'] ?? json['rejection_reason'],
      ),
      isFeatured: JsonConverters.boolValue(
        json['isFeatured'] ?? json['is_featured'],
      ),
      isTopChoice: JsonConverters.boolValue(
        json['isTopChoice'] ?? json['is_top_choice'],
      ),
      isVerified: JsonConverters.boolValue(
        json['isVerified'] ?? json['is_verified'],
      ),
      viewCount: JsonConverters.intValue(
        json['viewCount'] ?? json['view_count'],
      ),
      rating: JsonConverters.doubleValue(json['rating']),
      reviewCount: JsonConverters.intValue(
        json['reviewCount'] ?? json['review_count'],
      ),
      postedAt: JsonConverters.dateTimeValue(
        json['postedAt'] ?? json['posted_at'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (id != null) 'id': id,
      if (ownerId != null) 'ownerId': ownerId,
      if (listingType != null) 'listingType': listingType,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (categoryId != null) 'categoryId': categoryId,
      if (subcategoryId != null) 'subcategoryId': subcategoryId,
      if (rentalPrice != null) 'rentalPrice': rentalPrice,
      if (priceUnit != null) 'priceUnit': priceUnit,
      if (securityDeposit != null) 'securityDeposit': securityDeposit,
      if (brand != null) 'brand': brand,
      if (modelName != null) 'modelName': modelName,
      if (color != null) 'color': color,
      if (additionalDetails != null) 'additionalDetails': additionalDetails,
      if (profession != null) 'profession': profession,
      if (experience != null) 'experience': experience,
      if (skills != null) 'skills': skills,
      if (localAreaId != null) 'localAreaId': localAreaId,
      if (address != null) 'address': address,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (status != null) 'status': status,
      if (rejectionReason != null) 'rejectionReason': rejectionReason,
      if (isFeatured != null) 'isFeatured': isFeatured,
      if (isTopChoice != null) 'isTopChoice': isTopChoice,
      if (isVerified != null) 'isVerified': isVerified,
      if (viewCount != null) 'viewCount': viewCount,
      if (rating != null) 'rating': rating,
      if (reviewCount != null) 'reviewCount': reviewCount,
      if (postedAt != null) 'postedAt': postedAt!.toIso8601String(),
    };
  }
}
