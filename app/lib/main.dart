import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/material.dart' hide MenuItem;
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:window_manager/window_manager.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:path/path.dart' as path;
import 'services/data.dart';
import 'pages/messages.dart';
import 'pages/settings.dart';
import 'models/settings.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();
  WindowOptions windowOptions = WindowOptions(
    size: ui.Size(900, 600),
    center: true,
    title: 'PushPop',
    skipTaskbar: false,
  );

  await HiveService.init();
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.hide();
  });

  // Settings settings = getSettings();
  // windowManager.setPreventClose(settings.quitToTray);
  windowManager.setTitle("PushPop");

  appWindow.minSize = ui.Size(600, 400);

  localNotifier.setup(
    appName: 'PushPop',
    shortcutPolicy: ShortcutPolicy.requireCreate,
  );

  runApp(ProviderScope(child: PushPopApp()));
}

class PushPopApp extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PushPop',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TrayListener, WindowListener {
  int _selectedIndex = 0;
  static List<Widget> _pages = <Widget>[
    MessagesPage(),
    SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    trayManager.addListener(this);
    windowManager.addListener(this);
    _setTray();
  }

  Future<void> _setTray() async {
    String exePath = Platform.resolvedExecutable;
    String installDir = File(exePath).parent.path;
    String iconPath = path.join(installDir, 'data', 'flutter_assets', 'assets',
        'images', 'app_icon.ico');
    await trayManager.setIcon(Platform.isWindows ? iconPath : iconPath);

    await trayManager.setToolTip('PushPop');
    Menu menu = Menu(
      items: [
        MenuItem(
          key: 'show_window',
          label: '打开',
        ),
        MenuItem.separator(),
        MenuItem(
          key: 'exit_app',
          label: '退出',
        ),
      ],
    );
    await trayManager.setContextMenu(menu);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _restoreApp() async {
    await windowManager.show();
    await windowManager.focus();
  }

  @override
  void onTrayIconMouseDown() {
    _restoreApp();
  }

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayIconRightMouseUp() {
    // do something
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    if (menuItem.key == 'show_window') {
      _restoreApp();
    } else if (menuItem.key == 'exit_app') {
      exit(0);
    }
  }

  @override
  void onWindowClose() async {
    // bool isPreventClose = await windowManager.isPreventClose();
    Settings settings = getSettings();
    windowManager.setPreventClose(settings.quitToTray);
    bool quitToTray = settings.quitToTray;
    print("quittotray:$quitToTray");
    if (quitToTray) {
      await windowManager.hide();
    } else {
      await windowManager.destroy();
    }
  }

  @override
  void dispose() {
    trayManager.removeListener(this);
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width / 3,
            color: Colors.blueGrey[50],
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'PushPop',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 40),
                ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.sms),
                      SizedBox(width: 8),
                      Text(
                        '消息',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  selected: _selectedIndex == 0,
                  onTap: () {
                    _onItemTapped(0);
                  },
                ),
                ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.settings),
                      SizedBox(width: 8),
                      Text(
                        '设置',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  selected: _selectedIndex == 1,
                  onTap: () {
                    _onItemTapped(1);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _pages[_selectedIndex],
          ),
        ],
      ),
    );
  }
}
