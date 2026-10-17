class BusinessModel {
  final String publicId;
  final String businessName;
  final String legalName;
  final String businessType;
  final String? logoUrl;
  final String? bannerUrl;
  final String city;
  final String province;
  final String verificationStatus;
  final int productCount;

  BusinessModel({
    required this.publicId,
    required this.businessName,
    required this.legalName,
    required this.businessType,
    this.logoUrl,
    this.bannerUrl,
    required this.city,
    required this.province,
    required this.verificationStatus,
    required this.productCount,
  });

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    return BusinessModel(
      publicId: json['public_id'] ?? '',
      businessName: json['business_name'] ?? '',
      legalName: json['legal_name'] ?? '',
      businessType: json['business_type'] ?? '',
      logoUrl: json['logo_url'],
      bannerUrl: json['banner_url'],
      city: json['city'] ?? '',
      province: json['province'] ?? '',
      verificationStatus: json['verification_status'] ?? '',
      productCount: json['product_count'] ?? 0,
    );
  }
}
