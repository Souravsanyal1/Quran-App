# Walkthrough - n8n Bot Control System

I have implemented a dual-layer control system for the n8n support bot, allowing both global and per-chat management from the Admin Panel.

## Changes Made

### 1. Global Bot Toggle (Firestore Integration)
- Moved the global `isLiveSupportBotEnabled` toggle from Realtime Database to Firestore (`app_settings/update_config`).
- Updated `SettingsController` to reactively listen to this flag, ensuring the entire app (including user-side chat) respects the global setting instantly.
- Updated `AdminDashboardController` to manage this flag within the existing "App Maintenance" configuration flow.

### 2. Per-Chat Bot Toggle
- Added `isBotActive` field to the `SupportTicket` model.
- Implemented a toggle switch in the Admin Chat interface (`_AdminChatView`).
- This allows admins to turn off the bot for a specific user session when they need to intervene manually, preventing the bot from responding while a human is helping.

### 3. Support Chat Logic
- Modified `SupportController` to check both flags before triggering an AI auto-reply:
    ```dart
    if (!settings.isLiveSupportBotEnabled.value || !ticket.isBotActive) {
      _logger.i('AI Auto-reply skipped...');
      return;
    }
    ```

## Verification Summary

### Automated Checks
- Analyzed key files (`SupportController`, `AdminDashboardController`) for syntax errors. No critical issues were found.

### Manual Verification Path (Recommended for User)
1. **Global Control**:
   - Go to **Admin Panel > Maintenance**.
   - Toggle **Live Support Bot** and Save.
   - Verify that no bot responses appear in any user chat when OFF.
2. **Per-Chat Control**:
   - Open a specific user's chat from the **Support Tickets** tab.
   - Use the **Bot On/Off** switch in the top-right corner of the chat window.
   - Verify that when OFF, the bot does not respond to that specific user's messages, even if the global setting is ON.
3. **Admin Intervention**:
   - Turn OFF the bot for a chat.
   - Type a manual response as an admin.
   - Confirm the user receives the message and no automated bot text follows.
