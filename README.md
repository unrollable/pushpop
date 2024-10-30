# PushPop

[github]: https://github.com/unrollable/pushpop

PushPop is a free, open-source client to push messages

- [PushPop](#pushpop)
  - [About](#about)
  - [Screenshots](#screenshots)
  - [Download](#download)
  - [How to push messages](#how-to-push-messages)
    - [Python](#python)
    - [Shell](#shell)
    - [Or other way u like...](#or-other-way-u-like)
  - [Get Start](#get-start)
  - [Build](#build)
    - [Windows](#windows)
  - [Note](#note)
  - [Donate](#donate)


## About
PoshPop is a free, open-source, lightweight message-pushing client. You can push messages to the client using custom scripts or the other HTTP tool. 
Of course, you can also use your own server as the backend.

## Screenshots
<img src="/doc/images/screenshot-message.jpg" alt="Screenshot Message" width="300" /><img src="/doc/images/screenshot-notice.jpg" alt="Screenshot Notice" width="355" />

## Download

| Windows                 |
|-------------------------|
| [EXE Installer][latest] |
| [Portable ZIP][latest]  |

[latest]: https://github.com/unrollable/pushpop/releases/latest

## How to push messages

### Python

```bash
import requests
import json

url = 'http://47.116.17.40:8000/message/push'
headers = {'Content-Type': 'application/json'}
data = {
    "apikey":"<ypur-api-key>",
    "type" :u"text",
    "title":u"吾日三省吾身:",
    "content":u"1.早上吃什么\n2.中午吃什么\n3.晚上吃什么"
    }
requests.post(url, headers=headers, json=data)
```

### Shell

```bash
curl -X POST http://47.116.17.40:8000/message/push \
     -H "Content-Type: application/json" \
     -d '{"apikey": "<your-api-key>", "type": "text", "title": "This is Title", "content": "This is Content"}'
```

### Or other way u like...


## Get Start

Compile PushPop from source code:

1. Install Flutter [directly](https://flutter.dev)
2. Clone the `PushPop` repository
3. Run `cd app`
4. Run `flutter pub get` to download dependencies
5. Run `flutter pub run build_runner build` to generate adapter file
6. Run `flutter run -d windows` to start the windows app


## Build

### Windows

```bash
flutter build windows
```

## Note
- If you want use your own server, follow these steps:
  -  open the`customServer` at settings page
  -  fill out your configurations
  -  click the button `reconnect` to connect your server
- The project is still under development and primarily for personal use. Any bug is possible, so please submit an [issue](https://github.com/unrollable/pushpop/issues).
- Do not use commercially

## Donate
<img src="/doc/images/alipay.jpg" alt="支付宝" width="300" />支付宝<img src="/doc/images/btc.jpg" alt="BTC" width="300" />BTC
