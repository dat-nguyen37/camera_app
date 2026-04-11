# FE

- cd FE
- flutter pub get
- flutter run

## BE

- cd BE
- npm install
- npm run start

## Chuẩn bị

1. Đăng ký tài khoản nhà phát triển

- Truy cập "[open.imoulife.com](https://isgpopen.ezviz.com/)" và đăng ký tài khoản nhà phát triển

2. Tạo ứng dụng trên Open Platform

- Add thiết bị

* URL:https://open.ezvizlife.com/api/lapp/device/add
* Method: POST

* Body (x-www-form-urlencoded):

* accessToken: (Token của bạn)

* deviceSerial: (9 chữ số của bạn)
* validateCode: (6 chữ số của bạn)

- Get thiết bị:

* URL: https://open.ezvizlife.com/api/lapp/live/address/get

* Method: POST

* Body (x-www-form-urlencoded):

* accessToken: (Token của bạn)

* deviceSerial: (9 chữ số của bạn)

* channelNo: 1

* protocol: 1 (để lấy link HLS - chạy được trên trình duyệt web)
* code: (6 chữ số của bạn)

## Kết nối app flutter tới camera
1. Cài thư viện gói ezviz_flutter
