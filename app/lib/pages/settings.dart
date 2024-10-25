import 'package:flutter/material.dart';
import 'package:pushpop/services/data.dart';
import 'package:pushpop/models/settings.dart';
import 'package:url_launcher/url_launcher.dart';

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
                _buildSwitchSetting(
                  'quitToTray',
                  '关闭时最小化到托盘',
                  settings.quitToTray,
                ),
                _buildSwitchSetting(
                  'autoStartup',
                  '开机自启',
                  settings.autoStartup,
                ),
                _buildSwitchSetting(
                  'hiddenStartup',
                  '自启到托盘',
                  settings.hiddenStartup,
                ),
              ],
            ),
            SizedBox(height: 20),
            _buildSettingsSection(
              title: '账户',
              children: [
                _buildUserSetting(context, '未登录'),
                SizedBox(height: 10),
                _buildApiKeySetting(context),
              ],
            ),
            SizedBox(height: 20),
            _buildSettingsSection(
              title: '其他',
              children: [
                _buildLinkRow(
                  '关于PushWave',
                  '查看',
                  'https://about.link'),
                SizedBox(height: 10),
                _buildLinkRow(
                  '支持PushWave',
                  '捐赠',
                  'https://support.link'),
                SizedBox(height: 10),
                _buildLinkRow(
                  '隐私政策',
                  '查看',
                  'https://privacy.link'),
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
    String selectedOption = options[0];
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
                onChanged: (String? newValue) async{
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

  Widget _buildUserSetting(BuildContext context, String username) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('$username'),
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
                  // Handle login/logout
                },
                child: Text(username == '未登录' ? '登录' : '登出'),
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
                    onPressed: () {
                      // Handle reset API key
                    },
                    child: Text('重置'),
                  ),
                  ElevatedButton(
                    onPressed: () {},
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
                onPressed: () async{
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
}
