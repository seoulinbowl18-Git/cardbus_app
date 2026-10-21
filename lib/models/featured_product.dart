import 'package:flutter/material.dart';

/// Kartu "Produk unggulan" ala e-commerce di beranda.
class FeaturedProduct {
  const FeaturedProduct({
    required this.id,
    required this.poName,
    required this.poShort,
    required this.poColor,
    required this.image,
    required this.busClass,
    required this.from,
    required this.to,
    required this.boardPoint,
    required this.tag,
    this.poId,
    this.logo,
    this.price,
    this.oldPrice,
    this.comingSoon = false,
  });

  final String id;
  final String? poId; // null jika PO belum punya jadwal di sistem
  final String poName;
  final String poShort;
  final Color poColor;
  final String? logo; // path asset
  final String image; // path asset
  final String busClass;
  final String from;
  final String to;
  final String boardPoint;
  final String tag; // BARU / PROMO / TERLARIS ...
  final int? price;
  final int? oldPrice;
  final bool comingSoon;
}
