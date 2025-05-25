import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/competition.dart';

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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Competition emblem
              if (competition.emblem.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: CachedNetworkImage(
                    imageUrl: competition.emblem,
                    height: 50,
                    width: 50,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => const SizedBox(
                      height: 50,
                      width: 50,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => const Icon(
                      Icons.sports_soccer,
                      size: 40,
                    ),
                  ),
                )
              else
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(Icons.sports_soccer),
                ),
              const SizedBox(width: 16),
              
              // Competition details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      competition.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (competition.area != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        competition.area!,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                        ),
                      ),
                    ],
                    if (competition.currentSeason != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Season: ${competition.currentSeason}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Arrow icon
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
