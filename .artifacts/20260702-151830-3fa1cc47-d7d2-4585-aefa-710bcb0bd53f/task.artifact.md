# Task Management

- [x] Modify `SupportTicket` model to include `isBotActive`
- [x] Update `SupportRepository` with `updateBotStatus` and mapping logic
- [x] Update `SettingsController` to listen for global bot status in Firestore
- [x] Update `AdminDashboardController` to manage global bot status in Firestore
- [x] Update `AdminChatController` with per-ticket bot toggle logic
- [x] Update `SupportController` to check bot status before auto-reply
- [x] Update `AdminDashboardView` UI with global and per-ticket toggles
- [x] Verify functionality
- [x] Git & hosting push
- [/] **Notification Management System**
    - [ ] Create `notification_config_model.dart`
    - [ ] Extend `NotificationRepository` for CRUD operations
    - [ ] Create `NotificationManagementController`
    - [ ] Update `AdminDashboardView` with "Notifications" tab
    - [ ] Update `NotificationService` to support remote configs
    - [ ] Update `SettingsController` to sync remote configs
    - [ ] Verify local scheduling updates based on remote config
