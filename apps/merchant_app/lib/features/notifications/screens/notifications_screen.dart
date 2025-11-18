import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';

enum NotificationType {
  paymentReminder,
  paymentReceived,
  dueDate,
  dispute,
  system,
}

class NotificationItem {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String? customerId;

  NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.customerId,
  });
}

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  NotificationType? _selectedFilter;

  // Mock data - will be replaced with actual provider
  final List<NotificationItem> _mockNotifications = [
    NotificationItem(
      id: '1',
      type: NotificationType.paymentReminder,
      title: 'Payment Reminder',
      message: 'Ram Sharma has an outstanding balance of Rs. 5,420',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      customerId: '1',
    ),
    NotificationItem(
      id: '2',
      type: NotificationType.paymentReceived,
      title: 'Payment Received',
      message: 'Sita Devi paid Rs. 2,000',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      isRead: true,
      customerId: '2',
    ),
    NotificationItem(
      id: '3',
      type: NotificationType.dueDate,
      title: 'Due Date Approaching',
      message: 'Hari Bahadur\'s payment is due in 2 days',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      customerId: '3',
    ),
    NotificationItem(
      id: '4',
      type: NotificationType.system,
      title: 'App Update Available',
      message: 'A new version of Fonepay Khata Book is available',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      isRead: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filteredNotifications = _selectedFilter == null
        ? _mockNotifications
        : _mockNotifications.where((n) => n.type == _selectedFilter).toList();

    final unreadCount = _mockNotifications.where((n) => !n.isRead).length;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Notifications'),
            if (unreadCount > 0)
              Text(
                '$unreadCount unread',
                style: AppTypography.labelSmall.copyWith(
                  color: Colors.white70,
                ),
              ),
          ],
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: Text(
                'Mark all read',
                style: AppTypography.bodySmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Notification Settings'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Clear All', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'settings') {
                _showNotificationSettings();
              } else if (value == 'clear') {
                _showClearAllDialog();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.backgroundLight,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'All',
                    isSelected: _selectedFilter == null,
                    count: _mockNotifications.length,
                    onTap: () => setState(() => _selectedFilter = null),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Reminders',
                    icon: Icons.notifications_active,
                    isSelected: _selectedFilter == NotificationType.paymentReminder,
                    count: _mockNotifications
                        .where((n) => n.type == NotificationType.paymentReminder)
                        .length,
                    onTap: () => setState(() => _selectedFilter = NotificationType.paymentReminder),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Payments',
                    icon: Icons.payment,
                    isSelected: _selectedFilter == NotificationType.paymentReceived,
                    count: _mockNotifications
                        .where((n) => n.type == NotificationType.paymentReceived)
                        .length,
                    onTap: () => setState(() => _selectedFilter = NotificationType.paymentReceived),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Due Dates',
                    icon: Icons.calendar_today,
                    isSelected: _selectedFilter == NotificationType.dueDate,
                    count: _mockNotifications
                        .where((n) => n.type == NotificationType.dueDate)
                        .length,
                    onTap: () => setState(() => _selectedFilter = NotificationType.dueDate),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'System',
                    icon: Icons.info_outline,
                    isSelected: _selectedFilter == NotificationType.system,
                    count: _mockNotifications
                        .where((n) => n.type == NotificationType.system)
                        .length,
                    onTap: () => setState(() => _selectedFilter = NotificationType.system),
                  ),
                ],
              ),
            ),
          ),

          // Notifications list
          Expanded(
            child: filteredNotifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No notifications',
                          style: AppTypography.bodyLarge.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'You\'re all caught up!',
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: filteredNotifications.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final notification = filteredNotifications[index];
                      return _NotificationTile(
                        notification: notification,
                        onTap: () => _handleNotificationTap(notification),
                        onDismiss: () => _dismissNotification(notification.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _handleNotificationTap(NotificationItem notification) {
    // Mark as read
    setState(() {
      // In real implementation, update via provider
    });

    // Navigate based on notification type
    if (notification.customerId != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Navigate to customer ${notification.customerId}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      // In real app: context.pushNamed('customerDetail', pathParameters: {'id': notification.customerId!});
    }
  }

  void _dismissNotification(String id) {
    setState(() {
      _mockNotifications.removeWhere((n) => n.id == id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notification removed'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _markAllAsRead() {
    setState(() {
      // In real implementation, update via provider
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showNotificationSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notification Settings',
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Payment Reminders'),
              subtitle: const Text('Get notified about pending payments'),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: const Text('Payment Received'),
              subtitle: const Text('Get notified when customers pay'),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: const Text('Due Date Alerts'),
              subtitle: const Text('Alerts for upcoming due dates'),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: const Text('System Notifications'),
              subtitle: const Text('App updates and announcements'),
              value: false,
              onChanged: (value) {},
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Notifications?'),
        content: const Text('This will permanently delete all notifications. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _mockNotifications.clear();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All notifications cleared'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final int count;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    this.icon,
    required this.isSelected,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : AppColors.gray600,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: isSelected ? Colors.white : AppColors.gray600,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: AppTypography.labelSmall.copyWith(
                    color: isSelected ? AppColors.primary : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationItem notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onDismiss(),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _getNotificationColor(notification.type).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            _getNotificationIcon(notification.type),
            color: _getNotificationColor(notification.type),
            size: 24,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                notification.title,
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                ),
              ),
            ),
            if (!notification.isRead)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.message,
              style: AppTypography.bodySmall.copyWith(
                color: Colors.grey[700],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              _formatTimestamp(notification.timestamp),
              style: AppTypography.labelSmall.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: onTap,
        tileColor: notification.isRead ? null : AppColors.backgroundLight,
      ),
    );
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.paymentReminder:
        return Icons.notifications_active;
      case NotificationType.paymentReceived:
        return Icons.payment;
      case NotificationType.dueDate:
        return Icons.calendar_today;
      case NotificationType.dispute:
        return Icons.warning;
      case NotificationType.system:
        return Icons.info;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.paymentReminder:
        return AppColors.advanceYellow;
      case NotificationType.paymentReceived:
        return AppColors.debitGreen;
      case NotificationType.dueDate:
        return AppColors.creditRed;
      case NotificationType.dispute:
        return Colors.orange;
      case NotificationType.system:
        return AppColors.info;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}
