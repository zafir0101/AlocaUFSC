import 'package:flutter/material.dart';

import '../../../theme.dart';
import 'venue_model.dart';

class VenueCard extends StatelessWidget {
  final Venue venue;
  final VoidCallback? onTap;
  final Widget? trailing;

  const VenueCard({super.key, required this.venue, this.onTap, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      venue.code,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.mainBlue),
                    ),
                    const SizedBox(height: 2),
                    Text(venue.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    _InfoRow(icon: Icons.place_outlined, text: venue.location),
                    const SizedBox(height: 4),
                    _InfoRow(icon: Icons.people_outline, text: '${venue.capacity} pessoas'),
                    const SizedBox(height: 4),
                    _InfoRow(icon: Icons.verified_user_outlined, text: venue.allowedRolesLabel),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Expanded(child: Text(text, style: const TextStyle(color: AppColors.textSecondary))),
      ],
    );
  }
}
