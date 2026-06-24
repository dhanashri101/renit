class ListingModel {
  final int id;
  final int ownerId;
  final String listingType;
  final String title;
  final String description;
  final int categoryId;
  final int subcategoryId;
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
  final DateTime postedAt;

  ListingModel({
    required this.id,
    required this.ownerId,
    required this.listingType,
    required this.title,
    required this.description,
    required this.categoryId,
    required this.subcategoryId,
    required this.rentalPrice,
    required this.priceUnit,
    required this.securityDeposit,
    required this.brand,
    required this.modelName,
    required this.color,
    required this.additionalDetails,
    required this.profession,
    required this.experience,
    required this.skills,
    required this.localAreaId,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.rejectionReason,
    required this.isFeatured,
    required this.isTopChoice,
    required this.isVerified,
    required this.viewCount,
    required this.rating,
    required this.reviewCount,
    required this.postedAt,
  });

  factory ListingModel.fromJson(Map<String, dynamic> json) {
    return ListingModel(
      id: json['id'] ?? 0,
      ownerId: json['ownerId'] ?? 0,
      listingType: json['listingType'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      categoryId: json['categoryId'] ?? 0,
      subcategoryId: json['subcategoryId'] ?? 0,
      rentalPrice: (json['rentalPrice'] ?? 0).toDouble(),
      priceUnit: json['priceUnit'] ?? '',
      securityDeposit: (json['securityDeposit'] ?? 0).toDouble(),
      brand: json['brand'] ?? '',
      modelName: json['modelName'] ?? '',
      color: json['color'] ?? '',
      additionalDetails: json['additionalDetails'] ?? '',
      profession: json['profession'] ?? '',
      experience: json['experience'] ?? '',
      skills: json['skills'] ?? '',
      localAreaId: json['localAreaId'] ?? 0,
      address: json['address'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      rejectionReason: json['rejectionReason'] ?? '',
      isFeatured: json['isFeatured'] ?? false,
      isTopChoice: json['isTopChoice'] ?? false,
      isVerified: json['isVerified'] ?? false,
      viewCount: json['viewCount'] ?? 0,
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      postedAt: DateTime.tryParse(json['postedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'listingType': listingType,
      'title': title,
      'description': description,
      'categoryId': categoryId,
      'subcategoryId': subcategoryId,
      'rentalPrice': rentalPrice,
      'priceUnit': priceUnit,
      'securityDeposit': securityDeposit,
      'brand': brand,
      'modelName': modelName,
      'color': color,
      'additionalDetails': additionalDetails,
      'profession': profession,
      'experience': experience,
      'skills': skills,
      'localAreaId': localAreaId,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      'rejectionReason': rejectionReason,
      'isFeatured': isFeatured,
      'isTopChoice': isTopChoice,
      'isVerified': isVerified,
      'viewCount': viewCount,
      'rating': rating,
      'reviewCount': reviewCount,
      'postedAt': postedAt.toIso8601String(),
    };
  }
}
