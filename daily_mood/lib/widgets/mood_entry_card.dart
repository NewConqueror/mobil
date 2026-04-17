import 'package:flutter/material.dart';
import '../models/mood_entry.dart';
import '../utils/mood_colors.dart';
import '../utils/date_extensions.dart';

class MoodEntryCard extends StatelessWidget {
  final MoodEntry entry;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool showDate;
  final bool compact;

  const MoodEntryCard({
    super.key,
    required this.entry,
    this.onTap,
    this.onDelete,
    this.showDate = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: compact ? 8 : 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.all(compact ? 12 : 16),
            decoration: BoxDecoration(
              color: MoodColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: MoodColors.getSecondaryColor(entry.mood),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: MoodColors.getColor(entry.mood).withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Mood emoji and indicator
                Container(
                  width: compact ? 50 : 60,
                  height: compact ? 50 : 60,
                  decoration: BoxDecoration(
                    color: MoodColors.getSecondaryColor(entry.mood),
                    borderRadius: BorderRadius.circular(compact ? 25 : 30),
                    border: Border.all(
                      color: MoodColors.getPrimaryColor(entry.mood),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      entry.mood.emoji,
                      style: TextStyle(
                        fontSize: compact ? 20 : 24,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date and mood name
                      Row(
                        children: [
                          if (showDate) ...[
                            Text(
                              entry.date.relativDateString,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: MoodColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: MoodColors.textSecondary,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            entry.mood.displayName,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: MoodColors.getPrimaryColor(entry.mood),
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                      
                      if (entry.note.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          entry.note,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: MoodColors.textPrimary,
                                height: 1.3,
                              ),
                          maxLines: compact ? 2 : 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      
                      if (showDate && !compact) ...[
                        const SizedBox(height: 8),
                        Text(
                          entry.date.formattedTime,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: MoodColors.textSecondary,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Actions
                if (onDelete != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: onDelete,
                    icon: Icon(
                      Icons.delete_outline,
                      color: MoodColors.textSecondary,
                      size: compact ? 20 : 24,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Today's mood card with special styling
class TodayMoodCard extends StatelessWidget {
  final MoodEntry? entry;
  final VoidCallback onAddMood;
  final VoidCallback? onEditMood;

  const TodayMoodCard({
    super.key,
    this.entry,
    required this.onAddMood,
    this.onEditMood,
  });

  @override
  Widget build(BuildContext context) {
    if (entry == null) {
      return _buildAddMoodCard(context);
    } else {
      return _buildExistingMoodCard(context, entry!);
    }
  }

  Widget _buildAddMoodCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            MoodColors.accent.withOpacity(0.1),
            MoodColors.accent.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: MoodColors.accent.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: MoodColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                color: MoodColors.accent.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: const Center(
              child: Text('😊', style: TextStyle(fontSize: 32)),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Bugünkü ruh halin nasıl?',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: MoodColors.textPrimary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Ruh halini kaydetmek için dokunun',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: MoodColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onAddMood,
            style: ElevatedButton.styleFrom(
              backgroundColor: MoodColors.accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 2,
            ),
            child: const Text(
              'Ruh Halimi Kaydet',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExistingMoodCard(BuildContext context, MoodEntry entry) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            MoodColors.getColor(entry.mood).withOpacity(0.2),
            MoodColors.getColor(entry.mood).withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: MoodColors.getPrimaryColor(entry.mood),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: MoodColors.getSecondaryColor(entry.mood),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: MoodColors.getPrimaryColor(entry.mood),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    entry.mood.emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bugün ${entry.mood.displayName.toLowerCase()} hissediyorsun',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: MoodColors.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.date.formattedTime,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: MoodColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              if (onEditMood != null)
                IconButton(
                  onPressed: onEditMood,
                  icon: const Icon(Icons.edit_outlined),
                  color: MoodColors.getPrimaryColor(entry.mood),
                ),
            ],
          ),
          if (entry.note.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                entry.note,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: MoodColors.textPrimary,
                      height: 1.4,
                    ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
