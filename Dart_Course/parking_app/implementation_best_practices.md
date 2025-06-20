# ParkMe Settings - Implementation Best Practices

## Security Best Practices

### 1. Password Security
```dart
// Use proper password hashing (never store plain text)
class SecurityService {
  static String hashPassword(String password) {
    // Use bcrypt or similar in production
    return BCrypt.hashpw(password, BCrypt.gensalt());
  }
  
  static bool verifyPassword(String password, String hash) {
    return BCrypt.checkpw(password, hash);
  }
}
```

### 2. Email Verification Flow
```dart
class EmailVerificationService {
  Future<void> sendVerificationEmail(String newEmail) async {
    // Generate secure token
    final token = _generateSecureToken();
    
    // Store token with expiry (24 hours)
    await _storeVerificationToken(newEmail, token);
    
    // Send email with verification link
    await _sendVerificationEmail(newEmail, token);
  }
  
  String _generateSecureToken() {
    // Use crypto-secure random generation
    return base64Url.encode(List.generate(32, (_) => Random.secure().nextInt(256)));
  }
}
```

### 3. Input Validation & Sanitization
```dart
class ValidationService {
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) return 'Email is required';
    
    // RFC 5322 compliant regex
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(email)) return 'Invalid email format';
    
    // Additional security checks
    if (email.length > 254) return 'Email too long';
    
    return null;
  }
  
  static PasswordValidation validatePassword(String password) {
    return PasswordValidation(
      isValid: password.length >= 8 &&
               password.contains(RegExp(r'[a-z]')) &&
               password.contains(RegExp(r'[A-Z]')) &&
               password.contains(RegExp(r'[0-9]')) &&
               password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')),
      requirements: _getPasswordRequirements(password),
    );
  }
}
```

## Performance Best Practices

### 1. Efficient State Management
```dart
// Use BLoC pattern for complex state
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(SettingsInitial()) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateNotificationSettings>(_onUpdateNotificationSettings);
    on<ChangeEmail>(_onChangeEmail);
    on<ChangePassword>(_onChangePassword);
  }
  
  Future<void> _onLoadSettings(LoadSettings event, Emitter<SettingsState> emit) async {
    emit(SettingsLoading());
    try {
      final settings = await _settingsRepository.getSettings();
      emit(SettingsLoaded(settings));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }
}
```

### 2. Optimized Widget Building
```dart
// Use const constructors where possible
class SettingsSection extends StatelessWidget {
  const SettingsSection({
    super.key,
    required this.title,
    required this.children,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Use RepaintBoundary for expensive widgets
        RepaintBoundary(
          child: _SectionHeader(title: title),
        ),
        ...children,
      ],
    );
  }
}

// Use ValueListenableBuilder for specific state updates
class NotificationToggle extends StatelessWidget {
  final ValueNotifier<bool> notifier;
  
  const NotificationToggle({super.key, required this.notifier});
  
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: notifier,
      builder: (context, value, child) {
        return SwitchListTile(
          value: value,
          onChanged: (newValue) => notifier.value = newValue,
          title: const Text('Notifications'),
        );
      },
    );
  }
}
```

### 3. Lazy Loading and Caching
```dart
class SettingsRepository {
  final Map<String, dynamic> _cache = {};
  
  Future<UserSettings> getUserSettings() async {
    // Check cache first
    if (_cache.containsKey('user_settings')) {
      return UserSettings.fromJson(_cache['user_settings']);
    }
    
    // Load from remote/local storage
    final settings = await _loadUserSettings();
    _cache['user_settings'] = settings.toJson();
    
    return settings;
  }
  
  // Implement cache invalidation
  void invalidateCache(String key) {
    _cache.remove(key);
  }
}
```

## Accessibility Best Practices

### 1. Semantic Labels and Descriptions
```dart
class AccessibleSettingsItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  
  const AccessibleSettingsItem({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: title,
      hint: subtitle,
      button: onTap != null,
      child: ListTile(
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}
```

### 2. Focus Management
```dart
class AccessibleDialog extends StatefulWidget {
  @override
  State<AccessibleDialog> createState() => _AccessibleDialogState();
}

class _AccessibleDialogState extends State<AccessibleDialog> {
  late FocusNode _firstFocusNode;
  late FocusNode _lastFocusNode;
  
  @override
  void initState() {
    super.initState();
    _firstFocusNode = FocusNode();
    _lastFocusNode = FocusNode();
    
    // Auto-focus first element
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _firstFocusNode.requestFocus();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return FocusTraversalGroup(
      child: AlertDialog(
        content: Column(
          children: [
            TextFormField(
              focusNode: _firstFocusNode,
              decoration: const InputDecoration(labelText: 'First Field'),
            ),
            // ... other fields
            ElevatedButton(
              focusNode: _lastFocusNode,
              onPressed: () {},
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 3. Screen Reader Support
```dart
// Use Semantics widgets for complex interactions
Widget buildToggleWithSemantics(bool value, ValueChanged<bool> onChanged) {
  return Semantics(
    toggled: value,
    onTap: () => onChanged(!value),
    label: 'Notifications toggle',
    hint: value ? 'Tap to disable notifications' : 'Tap to enable notifications',
    child: Switch(
      value: value,
      onChanged: onChanged,
    ),
  );
}
```

## Platform-Specific Considerations

### iOS Specific
```dart
// Use Cupertino widgets for iOS
class PlatformSpecificSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          middle: Text('Settings'),
        ),
        child: _buildIOSSettings(),
      );
    }
    
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: _buildAndroidSettings(),
    );
  }
  
  Widget _buildIOSSettings() {
    return CupertinoListSection.insetGrouped(
      children: [
        CupertinoListTile(
          title: const Text('Notifications'),
          trailing: CupertinoSwitch(
            value: true,
            onChanged: (value) {},
          ),
        ),
      ],
    );
  }
}
```

### Android Specific
```dart
// Handle Android permissions
class AndroidPermissionHandler {
  Future<bool> requestNotificationPermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      
      if (androidInfo.version.sdkInt >= 33) {
        final status = await Permission.notification.request();
        return status == PermissionStatus.granted;
      }
    }
    return true;
  }
}
```

## Error Handling and User Feedback

### 1. Graceful Error Handling
```dart
class SettingsErrorHandler {
  static void handleError(BuildContext context, dynamic error) {
    String message;
    Color backgroundColor;
    
    if (error is NetworkException) {
      message = 'Network error. Please check your connection.';
      backgroundColor = Colors.orange;
    } else if (error is ValidationException) {
      message = error.message;
      backgroundColor = Colors.red;
    } else {
      message = 'An unexpected error occurred. Please try again.';
      backgroundColor = Colors.red;
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        action: SnackBarAction(
          label: 'Retry',
          onPressed: () {
            // Implement retry logic
          },
        ),
      ),
    );
  }
}
```

### 2. Loading States
```dart
class LoadingStateWidget extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? loadingText;
  
  const LoadingStateWidget({
    super.key,
    required this.isLoading,
    required this.child,
    this.loadingText,
  });
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black26,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  if (loadingText != null) ...[
                    const SizedBox(height: 16),
                    Text(loadingText!),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}
```

## Data Persistence and Synchronization

### 1. Local Storage
```dart
class SettingsStorage {
  static const String _key = 'user_settings';
  
  Future<void> saveSettings(UserSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(settings.toJson()));
  }
  
  Future<UserSettings?> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    
    if (json != null) {
      return UserSettings.fromJson(jsonDecode(json));
    }
    
    return null;
  }
}
```

### 2. Cloud Synchronization
```dart
class CloudSettingsSync {
  Future<void> syncSettings(UserSettings localSettings) async {
    try {
      // Get server settings
      final serverSettings = await _getServerSettings();
      
      // Merge with local settings (conflict resolution)
      final mergedSettings = _mergeSettings(localSettings, serverSettings);
      
      // Update both local and server
      await Future.wait([
        _saveLocalSettings(mergedSettings),
        _updateServerSettings(mergedSettings),
      ]);
    } catch (e) {
      // Handle sync errors gracefully
      _handleSyncError(e);
    }
  }
}
```

## Testing Strategies

### 1. Unit Tests
```dart
void main() {
  group('SettingsValidation', () {
    test('should validate email correctly', () {
      expect(ValidationService.validateEmail('test@example.com'), isNull);
      expect(ValidationService.validateEmail('invalid-email'), isNotNull);
      expect(ValidationService.validateEmail(''), isNotNull);
    });
    
    test('should validate password strength', () {
      final weak = ValidationService.validatePassword('123');
      expect(weak.isValid, isFalse);
      
      final strong = ValidationService.validatePassword('StrongP@ss123');
      expect(strong.isValid, isTrue);
    });
  });
}
```

### 2. Widget Tests
```dart
void main() {
  testWidgets('Settings screen shows all sections', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (context) => MockSettingsBloc(),
          child: const SettingsScreen(),
        ),
      ),
    );
    
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Account Management'), findsOneWidget);
    expect(find.text('App Preferences'), findsOneWidget);
  });
}
```

### 3. Integration Tests
```dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  testWidgets('Complete email change flow', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    
    // Navigate to settings
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();
    
    // Open change email dialog
    await tester.tap(find.text('Change Email Address'));
    await tester.pumpAndSettle();
    
    // Fill form and submit
    await tester.enterText(find.byType(TextFormField).first, 'new@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'new@example.com');
    await tester.enterText(find.byType(TextFormField).at(2), 'password123');
    
    await tester.tap(find.text('Change Email'));
    await tester.pumpAndSettle();
    
    // Verify success message
    expect(find.text('confirmation link has been sent'), findsOneWidget);
  });
}
```

This comprehensive implementation guide ensures security, performance, accessibility, and maintainability across both iOS and Android platforms.
