# Notification Management System Implementation Plan

This plan outlines the implementation of a comprehensive Notification Management System in the Qurania Admin Panel, allowing admins to control daily reminders, prayer alerts, and custom scheduled notifications.

## User Review Required

- **Global Sync**: Users will need to fetch these configurations from Firestore and update their local notification schedules accordingly.
- **Custom Notifications**: For custom notifications with "Repeat" logic, we will handle this via client-side scheduling or a cloud function (if available). For now, we'll focus on client-side scheduling based on fetched configs.

## Proposed Changes

### Data Models

#### [NEW] [notification_config_model.dart](file:///C:/Users/Sourav sanyal/OneDrive/Desktop/Quran App/lib/data/models/notification_config_model.dart)
- `NotificationCategoryConfig`: For fixed categories (Daily Quran, Prayer, etc.)
- `CustomNotificationConfig`: For admin-added custom notifications.

---

### Repositories

#### [notification_repository.dart](file:///C:/Users/Sourav sanyal/OneDrive/Desktop/Quran App/lib/data/repositories/notification_repository.dart)
- Add methods to fetch and update `notification_configs` in Firestore.
- Add methods for CRUD on `custom_notifications`.

---

### Admin Panel (Modules)

#### [NEW] [notification_management_controller.dart](file:///C:/Users/Sourav sanyal/OneDrive/Desktop/Quran App/lib/modules/admin_dashboard/notification_management_controller.dart)
- State management for all notification categories.
- Logic for adding/editing custom notifications.
- Firestore sync logic.

#### [admin_dashboard_view.dart](file:///C:/Users/Sourav sanyal/OneDrive/Desktop/Quran App/lib/modules/admin_dashboard/admin_dashboard_view.dart)
- Add a new "Notifications" tab in the sidebar and mobile bottom nav.
- Implement `_buildNotificationsTab` with sections for each category.
- Implement a table/list for custom notifications.

---

### Client-Side Integration

#### [settings_controller.dart](file:///C:/Users/Sourav sanyal/OneDrive/Desktop/Quran App/lib/modules/settings/settings_controller.dart)
- Listen to `notification_configs` in Firestore.
- Trigger re-scheduling of local notifications when configs change.

#### [notification_service.dart](file:///C:/Users/Sourav sanyal/OneDrive/Desktop/Quran App/lib/services/notification_service.dart)
- Update scheduling methods (`scheduleDuaReminder`, `scheduleAzanNotifications`, etc.) to accept parameters from the new configs instead of hardcoded or local-only values.
- Add logic to handle `CustomNotificationConfig`.

## Firestore Schema

```text
app_settings/
  notification_configs/ (Document)
    categories: {
      daily_quran: { enabled: bool, title: string, message: string, time: string },
      prayer: { enabled: bool, title: string, message: string, time: string },
      daily_dua: { enabled: bool, title: string, message: string },
      morning: { enabled: bool, title: string, message: string, time: string },
      evening: { enabled: bool, title: string, message: string, time: string },
      friday: { enabled: bool, title: string, message: string, time: string },
      ramadan: { enabled: bool, title: string, message: string, time: string },
    }

custom_notifications/ (Collection)
  {id}: {
    type: string,
    title: string,
    message: string,
    scheduleTime: string,
    startDate: timestamp,
    endDate: timestamp,
    repeat: string,
    priority: string,
    isActive: bool
  }
```

## Verification Plan

### Automated Tests
- N/A

### Manual Verification
1. **Admin Panel**:
   - Change the title/message of "Daily Du'a" in Admin Panel.
   - Verify it's saved in Firestore.
   - Verify the client app reflects this change in its next scheduled notification (mocking the time if needed).
2. **Custom Notifications**:
   - Add a custom notification with "Repeat: Daily".
   - Verify it appears in the admin table.
   - Verify the client app receives it and schedules it.
3. **Toggle**:
   - Disable "Prayer Reminder" globally.
   - Verify all users' prayer reminders are cancelled or not scheduled.
