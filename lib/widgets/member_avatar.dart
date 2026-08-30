import 'package:flutter/material.dart';
import '../models/member.dart';

class MemberAvatar extends StatelessWidget {
  final Member? member;
  final String? emoji;
  final String? name;
  final double size;
  final bool showBadge;
  final Color? customBgColor;

  const MemberAvatar({
    super.key,
    this.member,
    this.emoji,
    this.name,
    this.size = 40,
    this.showBadge = false,
    this.customBgColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveEmoji = member?.emoji ?? emoji ?? '🐟';
    final effectiveColor =
        customBgColor ?? (member != null ? Color(member!.colorValue) : const Color(0xFF0F4C81));

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: effectiveColor.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: Border.all(
          color: effectiveColor.withValues(alpha: 0.5),
          width: size > 40 ? 2 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: effectiveColor.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          effectiveEmoji,
          style: TextStyle(
            fontSize: size * 0.52,
          ),
        ),
      ),
    );
  }
}
