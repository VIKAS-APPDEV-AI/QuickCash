import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:quickcash/Screens/CryptoScreen/utils/CryptoImageUtils.dart';
import 'package:quickcash/Screens/NotificationsScreen.dart/NotificationAPI/NotificationsAPI.dart';
import 'package:quickcash/Screens/NotificationsScreen.dart/NotificationModel/NotificationsModel.dart';
import 'package:quickcash/Screens/TicketsScreen/TicketScreen/DashboardTicketScreen.dart';
import 'package:quickcash/constants.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<NotificationModel> notifications = [];
  bool isLoading = true;
  bool hasError = false;
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      final fetchedNotifications =
          await _notificationService.getUserNotifications();
      setState(() {
        notifications = fetchedNotifications;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back,
              color: Colors.white,
            )),
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromARGB(255, 20, 20, 20), // Primary color
                Color(0xFF8A2BE2), // Slightly lighter for gradient effect
                Color(0x00000000), // Transparent at the bottom
              ],
              stops: [0.0, 0.7, 1.0],
            ),
          ),
        ),
        actions: [
          
           IconButton(
            icon: const Icon(CupertinoIcons.headphones, color: Colors.white,),
            onPressed: () {
             Navigator.push(context, CupertinoPageRoute(builder: (context) => DashboardTicketScreen(),));
            },
            tooltip: 'Support',
          ),
          const SizedBox(width: 15),

        ],
      ),
      body: isLoading
          ?  Center(child: SpinKitWaveSpinner(size: 70, color: Theme.of(context).extension<AppColors>()!.primary,))
          : hasError
              ? const Center(child: Text('Failed to load notifications'))
              : RefreshIndicator(
                backgroundColor: AppColors.light.background,
                  onRefresh: fetchNotifications,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      bool isTablet = constraints.maxWidth > 600;
                      return ListView.builder(
                        padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          final notification = notifications[index];
                          return NotificationCard(
                            notification: notification,
                            isTablet: isTablet,
                          );
                        },
                      );
                    },
                  ),
                ),
    );
  }
}

class NotificationCard extends StatefulWidget {
  final NotificationModel notification;
  final bool isTablet;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.isTablet,
  });

  @override
  State<NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<NotificationCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.97, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showNotificationDetails(NotificationModel notification) {
    final formattedDate = DateFormat('MMM dd, yyyy • hh:mm a')
        .format(DateTime.parse(notification.createdAt));

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.8), // translucent background
      builder: (_) => Dialog(
        backgroundColor: Colors.white, // pure white dialog
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: widget.isTablet ? 500 : double.infinity,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Title
                  Text(
                    notification.title,
                    style: TextStyle(
                      fontSize: widget.isTablet ? 20 : 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),

                  /// Message
                  Text(
                    notification.message,
                    style: TextStyle(
                      fontSize: widget.isTablet ? 16 : 14,
                      color: Colors.grey.shade800,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),

                  /// Divider
                  Divider(color: Colors.grey.shade300),

                  /// Tags
                  if (notification.tags.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      "Tags:",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: -8,
                      children: notification.tags
                          .map((tag) => Chip(
                                label: Text(tag),
                                backgroundColor: Colors.blue.shade50,
                                labelStyle: const TextStyle(fontSize: 12, color: Colors.black),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 0),
                                visualDensity: VisualDensity.compact,
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  /// Info Fields
                  _buildInfoRow("Notify From", notification.notifyFrom),
                  _buildInfoRow("Notify Type", notification.notifyType),
                  _buildInfoRow("Created At", formattedDate),
                  if (notification.userDetails.isNotEmpty)
                    _buildInfoRow(
                      "User(s)",
                      notification.userDetails.map((e) => e.name).join(", "),
                    ),

                  const SizedBox(height: 20),

                  /// Close Button
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      label: const Text("Close"),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue.shade700,
                        textStyle: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              "$label:",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.black87,
                fontSize: widget.isTablet ? 14 : 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notification = widget.notification;
    final formattedDate = DateFormat('MMM dd, yyyy • hh:mm a')
        .format(DateTime.parse(notification.createdAt));

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        margin: EdgeInsets.symmetric(
          vertical: 10,
          horizontal: widget.isTablet ? 24.0 : 10.0,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.20),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon/Image
              // Container(
              //   width: 48,
              //   height: 48,
              //   decoration: BoxDecoration(
              //     color: notification.notifyType == 'crypto'
              //         ? Colors.transparent
              //         : Colors.grey.shade200,
              //     borderRadius: BorderRadius.circular(12),
              //   ),
              //   child: notification.notifyType == 'crypto'
              //       ? ClipRRect(
              //           borderRadius: BorderRadius.circular(8),
              //           child: Image.network(
              //             ImageUtils.getImageForTransferType(notification.title.toUpperCase()),
              //             fit: BoxFit.contain,
              //             errorBuilder: (_, __, ___) =>
              //                 const Icon(Icons.currency_bitcoin),
              //           ),
              //         )
              //       : Icon(
              //           Icons.notifications,
              //           size: 28,
              //           color: Colors.grey.shade700,
              //         ),
              // ),
              const SizedBox(width: 16),
              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: TextStyle(
                        fontSize: widget.isTablet ? 18 : 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: widget.isTablet ? 16 : 14,
                        color: const Color.fromARGB(255, 17, 16, 16),
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    if (notification.tags.isNotEmpty)
                      Wrap(
                        spacing: 6,
                        runSpacing: -8,
                        children: notification.tags
                            .map(
                              (tag) => Chip(
                                backgroundColor: Colors.blue.shade50,
                                label: Text(
                                  tag,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue.shade800,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 0,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: widget.isTablet ? 14 : 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        IconButton(
                          icon:  Icon(
                            Icons.remove_red_eye_rounded,
                            size: 22,
                            color: Theme.of(context).extension<AppColors>()!.primary,
                          ),
                          tooltip: 'View Details',
                          onPressed: () =>
                              _showNotificationDetails(notification),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Unread indicator
              if (!notification.read)
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
