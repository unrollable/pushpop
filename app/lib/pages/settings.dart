import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pushpop/services/msg_provider.dart';
import 'package:pushpop/services/data.dart';
import 'package:pushpop/models/settings.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pushpop/utils/util.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Settings settings = getSettings();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('设置'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildSettingsSection(
              title: '通用',
              children: [
                _buildDropdownSetting(
                  'language',
                  '语言',
                  ['简体中文', 'English'],
                ),
                SizedBox(height: 10),
                _buildSwitchSetting(
                  'quitToTray',
                  '关闭时最小化到托盘',
                  settings.quitToTray,
                ),
                SizedBox(height: 10),
                _buildSwitchSetting(
                  'autoStartup',
                  '开机自启',
                  settings.autoStartup,
                ),
                SizedBox(height: 10),
                _buildSwitchSetting(
                  'hiddenStartup',
                  '自启到托盘',
                  settings.hiddenStartup,
                ),
              ],
            ),
            SizedBox(height: 20),
            _buildSettingsSection(
              title: '网络',
              children: [
                Consumer(
                  builder: (context, ref, child) {
                    final messageNotifier = ref.read(messageProvider.notifier);
                    return _buildButtonSetting(
                      context,
                      '服务器',
                      '重连',
                      () => messageNotifier.loadInitialMessages(),
                    );
                  },
                ),
                SizedBox(height: 10),
                _buildSwitchSetting(
                  'customServer',
                  '自定义服务器',
                  settings.customServer,
                ),
                SizedBox(height: 10),
                if (settings.customServer) ...[
                  _buildTextFieldSetting(
                      'serverHost', '主机', settings.serverHost),
                  SizedBox(height: 10),
                  _buildTextFieldSetting(
                      'serverPort', '端口', settings.serverPort),
                  SizedBox(height: 10),
                  _buildSwitchSetting(
                    'enableSSL',
                    '启用SSL',
                    settings.enableSSL,
                  ),
                ],
              ],
            ),
            SizedBox(height: 20),
            _buildSettingsSection(
              title: '账户',
              children: [
                _buildButtonSetting(context, '未登录', '登录', signIn),
                SizedBox(height: 10),
                _buildApiKeySetting(context),
              ],
            ),
            SizedBox(height: 20),
            _buildSettingsSection(
              title: '其他',
              children: [
                _buildLinkRow('关于PushPop', '查看', 'https://about.link'),
                SizedBox(height: 10),
                _buildLinkRow('支持PushPop', '捐赠', 'https://support.link'),
                SizedBox(height: 10),
                _buildLinkRow('隐私政策', '查看', 'https://privacy.link'),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(
      {required String title, required List<Widget> children}) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDropdownSetting(String key, String title, List<String> options) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title),
        SizedBox(
          height: 50,
          width: 160,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: DropdownButton<String>(
                value: settings.language,
                onChanged: (String? newValue) async {
                  Settings updated = await updateSetting(key, newValue);
                  setState(() {
                    settings = updated;
                  });
                },
                underline: SizedBox(),
                items: options.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchSetting(String key, String title, bool initialValue) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title),
        SizedBox(
          height: 50,
          width: 160,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Switch(
                value: initialValue,
                onChanged: (dynamic newValue) async {
                  Settings updated = await updateSetting(key, newValue);
                  setState(() {
                    settings = updated;
                  });
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextFieldSetting(String key, String title, String initialValue) {
    TextEditingController controller =
        TextEditingController(text: initialValue);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title),
        SizedBox(
          height: 50,
          width: 160,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: TextField(
                controller: controller,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 0),
                ),
                onSubmitted: (value) async {
                  Settings updated = await updateSetting(key, value);
                  setState(() {
                    settings = updated;
                    // controller.text = updated.serverHost;
                  });
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButtonSetting(
      BuildContext context, String title, String opt, Function onClick) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('$title'),
        SizedBox(
          height: 50,
          width: 160,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  onClick();
                },
                child: Text(opt),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // APIKey
  Widget _buildApiKeySetting(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('API Key'),
        SizedBox(
          height: 50,
          width: 160,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      Settings updated =
                          await updateSetting('apiKey', genApiKey());
                      setState(() {
                        settings = updated;
                      });
                    },
                    child: Text('重置'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _showApiKeyDialog(context, settings.apiKey);
                    },
                    child: Text('查看'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLinkRow(String text, String opt, String url) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(text),
        SizedBox(
          height: 50,
          width: 160,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    throw 'Could not launch $url';
                  }
                },
                child: Text(opt),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void signIn() {
    print("wait to develope...");
  }

  void _showApiKeyDialog(BuildContext context, String apiKey) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // title: Text('API Key'),
          content:
              apiKey.isEmpty ? Text('还未创建API Key') : SelectableText(apiKey),
          actions: [
            if (apiKey.isNotEmpty)
              TextButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: apiKey));
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('clipboard!')),
                  );
                },
                child: Text('复制'),
              ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('关闭'),
            ),
          ],
        );
      },
    );
  }
}
