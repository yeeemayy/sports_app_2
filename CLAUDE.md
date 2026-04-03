# Sports App — Claude Guidelines

## Localization

This project uses `easy_localization` for all user-facing strings.

**Supported locales:** `zh-CN` (default), `en-GB`

**Translation files:** `assets/translations/<locale>.json`

### Rules

- **All user-facing strings must be localized.** Never hardcode display text in widgets.
- Add every new string to **both** `zh-CN.json` and `en-GB.json`.
- Use dot-notation keys grouped by feature, e.g. `nav.home`, `auth.login`, `profile.edit_title`.
- Use `.tr()` extension in widgets: `'some.key'.tr()`
- For strings with variables use `.tr(args: ['value'])` or `.tr(namedArgs: {'name': value})`.
- Do not use Flutter's built-in `intl`/`AppLocalizations` — stick to `easy_localization`.

## API Call Status Feedback

- **Never use `SnackBar`** for API call status updates.
- For **success** feedback: use `showCustomStatusDialog` from `lib/src/shared_widgets/custom_status_dialog.dart` with `DialogType.success`.
- For **error** feedback: use `context.showErrorDialog(title: ..., error: e)` from `lib/src/extensions/context_extensions.dart`. This handles `ApiClientException`, `AppException`, and unknown errors automatically.
