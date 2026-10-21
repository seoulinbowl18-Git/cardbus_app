import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';

/// Foto profil bulat. Foto hanya tampil jika pengguna memilih foto sendiri;
/// tanpa foto -> inisial nama, atau ikon orang jika nama belum ada.
/// [editable] menambah lencana kamera emas (ketuk = pilih dari galeri).
class AvatarWidget extends StatelessWidget {
  const AvatarWidget({super.key, this.size = 46, this.borderWidth = 2, this.editable = false, this.onTap});

  final double size;
  final double borderWidth;
  final bool editable;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final bytes = auth.avatarBytes;
    final url = auth.photoUrl;
    ImageProvider? photo;
    if (bytes != null) {
      photo = MemoryImage(bytes);
    } else if (url != null && url.startsWith('https://')) {
      photo = NetworkImage(url);
    }
    final name = auth.isLoggedIn ? (auth.name?.trim() ?? '') : '';
    final initial = name.isEmpty ? null : name.characters.first.toUpperCase();

    final Widget? placeholder = photo != null
        ? null
        : initial != null
            ? Center(
                child: Text(initial,
                    style: TextStyle(color: AppColors.teal, fontSize: size * 0.42, fontWeight: FontWeight.w800, height: 1)),
              )
            : ClipOval(child: CustomPaint(painter: _PersonPainter()));

    final circle = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.tealSoft,
        border: Border.all(color: AppColors.white, width: borderWidth),
        // onError: foto rusak / tautan mati tidak membuat error, cukup tampil warna latar.
        image: photo != null ? DecorationImage(image: photo, fit: BoxFit.cover, onError: (_, __) {}) : null,
      ),
      child: placeholder,
    );

    final badgeSize = size * 0.38;
    return Semantics(
      button: onTap != null,
      label: editable ? 'Ganti foto profil' : 'Profil saya',
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(clipBehavior: Clip.none, children: [
            circle,
            if (editable)
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  width: badgeSize,
                  height: badgeSize,
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 2),
                    boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 6, offset: Offset(0, 2))],
                  ),
                  child: Icon(Icons.photo_camera_rounded, size: badgeSize * 0.52, color: AppColors.ink),
                ),
              ),
          ]),
        ),
      ),
    );
  }
}

class _PersonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final paint = Paint()..color = AppColors.teal;
    canvas.drawCircle(Offset(s.width / 2, s.height * 0.40), s.width * 0.18, paint);
    canvas.drawOval(Rect.fromLTWH(s.width * 0.15, s.height * 0.68, s.width * 0.70, s.height * 0.62), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
