class BusinessKbli {
  final String code;
  final String name;
  final bool isPrimary;

  BusinessKbli({
    required this.code,
    required this.name,
    required this.isPrimary,
  });

  factory BusinessKbli.fromJson(Map<String, dynamic> json) => BusinessKbli(
        code: (json['code'] ?? '').toString(),
        name: (json['name'] ?? '').toString(),
        isPrimary: json['is_primary'] == 1 || json['is_primary'] == true,
      );
}

class Business {
  final String publicId;
  final String businessName;
  final String? legalName;
  final String slug;
  final String businessType;
  final String? description;
  final String? logoUrl;
  final String? bannerUrl;
  final String? email;
  final String? phone;
  final String? province;
  final String? city;
  final String? address;
  final String? nib;
  final String? taxNumber;
  final String? kbliCode;
  final String? kbliName;
  final String verificationStatus;
  final String status;
  final List<BusinessKbli> kbliList;

  Business({
    required this.publicId,
    required this.businessName,
    this.legalName,
    required this.slug,
    required this.businessType,
    this.description,
    this.logoUrl,
    this.bannerUrl,
    this.email,
    this.phone,
    this.province,
    this.city,
    this.address,
    this.nib,
    this.taxNumber,
    this.kbliCode,
    this.kbliName,
    required this.verificationStatus,
    required this.status,
    required this.kbliList,
  });

  factory Business.fromJson(Map<String, dynamic> json) {
    final rawKbli = json['kbli_list'];
    final kbliList = <BusinessKbli>[];
    if (rawKbli is List) {
      for (final item in rawKbli) {
        if (item is Map<String, dynamic>) {
          kbliList.add(BusinessKbli.fromJson(item));
        }
      }
    }

    return Business(
      publicId: (json['public_id'] ?? '').toString(),
      businessName: (json['business_name'] ?? '').toString(),
      legalName: json['legal_name']?.toString(),
      slug: (json['slug'] ?? '').toString(),
      businessType: (json['business_type'] ?? '').toString(),
      description: json['description']?.toString(),
      logoUrl: json['logo_url']?.toString(),
      bannerUrl: json['banner_url']?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      province: json['province']?.toString(),
      city: json['city']?.toString(),
      address: json['address']?.toString(),
      nib: json['nib']?.toString(),
      taxNumber: json['tax_number']?.toString(),
      kbliCode: json['kbli_code']?.toString(),
      kbliName: json['kbli_name']?.toString(),
      verificationStatus: (json['verification_status'] ?? 'unverified').toString(),
      status: (json['status'] ?? 'draft').toString(),
      kbliList: kbliList,
    );
  }

  bool get isVerified => verificationStatus == 'verified';

  String get locationDisplay {
    if (city == null && province == null) return 'Lokasi belum diisi';
    if (city == null) return province!;
    if (province == null) return city!;
    return '$city, $province';
  }
}