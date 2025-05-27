import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/competition.dart';
import '../utils/app_theme.dart';

class CompetitionItem extends StatelessWidget {
  final Competition competition;
  final VoidCallback onTap;

  const CompetitionItem({
    Key? key,
    required this.competition,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: AppTheme.modernCardDecoration(),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusLG),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
            children: [
              // Modern competition emblem with Hero animation
              Hero(
                tag: 'competition_${competition.id}',
                child: Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                    child: competition.emblem.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: competition.emblem,
                            height: 60,
                            width: 60,
                            fit: BoxFit.contain,
                            placeholder: (context, url) => Container(
                              decoration: AppTheme.gradientDecoration(gradient: AppTheme.primaryGradient),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: AppTheme.textLightColor,
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              decoration: AppTheme.gradientDecoration(gradient: AppTheme.primaryGradient),
                              child: const Icon(
                                Icons.emoji_events_outlined,
                                size: 30,
                                color: AppTheme.textLightColor,
                              ),
                            ),
                          )
                        : Container(
                            decoration: AppTheme.gradientDecoration(gradient: AppTheme.primaryGradient),
                            child: const Icon(
                              Icons.emoji_events_outlined,
                              size: 30,
                              color: AppTheme.textLightColor,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Modern competition details with typography
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      competition.name,
                      style: const TextStyle(
                        color: AppTheme.textPrimaryColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (competition.area != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.public,
                            size: 16,
                            color: AppTheme.textSecondaryColor,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              competition.area!,
                              style: const TextStyle(
                                color: AppTheme.textSecondaryColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (competition.currentSeason != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 16,
                            color: AppTheme.textSecondaryColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            competition.currentSeason!,
                            style: const TextStyle(
                              color: AppTheme.textSecondaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              
              // Modern arrow icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
