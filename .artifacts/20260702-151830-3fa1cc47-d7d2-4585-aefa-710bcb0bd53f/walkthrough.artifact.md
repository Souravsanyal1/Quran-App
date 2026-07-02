# Walkthrough - Notification Management System

I have implemented a comprehensive **Notification Management System** in the Qurania Admin Panel. This system allows admins to control all automated reminders and schedule custom notifications for all users.

## Key Features

### 1. Global Reminders Control
Admins can now customize the title, message, and schedule time for all standard app reminders:
- **Daily Quran Reminder**
- **Prayer Reminder**
- **Daily Du'a Reminder** (Time is automated, but Title/Message are customizable)
- **Morning & Evening Reminders**
- **Friday & Ramadan Reminders**

### 2. Custom Notifications
Admins can add unlimited custom scheduled notifications with:
- **Type, Title, and Message**
- **Specific Schedule Time** (HH:mm)
- **Repeat Logic**: Once, Daily, Weekly, or Monthly.
- **Priority Levels**: Low, Medium, High.
- **Start/End Dates**: Control when the notification campaign starts and ends.

### 3. Real-time Client Sync
The mobile app now listens to these configurations in Firestore. When an admin changes a notification's title, time, or status, the app automatically re-schedules the local notifications on the user's device.

## Technical Details

### New Components
- **[notification_config_model.dart](file:///C:/Users/Sourav%20sanyal/OneDrive/Desktop/Quran%20App/lib/data/models/notification_config_model.dart)**: Defines the data structure for global and custom notifications.
- **[notification_management_controller.dart](file:///C:/Users/Sourav%20sanyal/OneDrive/Desktop/Quran%20App/lib/modules/admin_dashboard/notification_management_controller.dart)**: Handles admin-side state and Firestore sync.
- **"Notifications" Tab**: Integrated into the `AdminDashboardView` sidebar and mobile navigation.

### Repository Updates
- **[notification_repository.dart](file:///C:/Users/Sourav%20sanyal/OneDrive/Desktop/Quran%20App/lib/data/repositories/notification_repository.dart)**: Added CRUD methods for `app_settings/notification_configs` and `custom_notifications` collection.

### Service Updates
- **[notification_service.dart](file:///C:/Users/Sourav%20sanyal/OneDrive/Desktop/Quran%20App/lib/services/notification_service.dart)**: Enhanced local scheduling logic to accept dynamic titles/messages and handle custom repeat patterns.

## Verification Summary

### Manual Verification Path
1. **Admin Panel**:
   - Go to the new **Notifications** tab.
   - Change the message for "Daily Du'a" and click **Save**.
   - Add a **Custom Notification** with "Repeat: Daily".
2. **Device Verification**:
   - The app will fetch the new configs and re-schedule local notifications.
   - Verify that the local notification (e.g., Du'a) now shows the new message set by the admin.
   - Verify that the custom notification appears at the scheduled time.
