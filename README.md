# LED Banner — Ứng dụng Chạy Chữ Đèn LED

Ứng dụng Flutter biến điện thoại hoặc máy tính bảng thành bảng hiệu đèn LED chạy chữ kỹ thuật số tuỳ chỉnh toàn diện — phù hợp cho concert, cổ vũ sự kiện, đón khách tại sân bay, tiệc sinh nhật, bảng quảng cáo cửa hàng hoặc giao tiếp nơi đông người.

---

## Tính năng chính

### 1. Trình soạn thảo & Xem trước trực tiếp (16:9)
- **Xem trước theo thời gian thực**: Hiển thị bảng LED 16:9 trực tiếp ngay khi chỉnh sửa, hỗ trợ tạm dừng/chạy thử và mở nhanh bảng vẽ hoặc chế độ toàn màn hình.
- **Nhập nội dung & Emoji nhanh**: Thanh nhập liệu kèm dãy emoji chèn nhanh (`❤️`, `🔥`, `⭐`, `🎉`, `🎤`, `👏`, `✈️`, `🎄`, `🎂`, `✨`).
- **Tạo kiểu ngẫu nhiên**: Nút xúc xắc tự động phối màu neon, phông chữ, hiệu ứng và nền có độ tương phản cao mà vẫn giữ nguyên nội dung chữ.

### 2. Tuỳ chỉnh Chữ & Chuyển động
- **Hướng chạy chữ**: Chạy sang trái, chạy sang phải hoặc đứng yên căn giữa.
- **Thông số hiển thị**: Điều chỉnh tốc độ chạy (`0.0x – 5.0x`), cỡ chữ (`25% – 95%` chiều cao bảng), khoảng cách giữa các ký tự (`-2.0 – 16.0`).
- **Kiểu chữ & Phông chữ**: Hỗ trợ In đậm, In nghiêng, Phản chiếu (Mirror) và 10 phông chữ đa dạng (Mặc định hệ thống, Be Vietnam Pro, Montserrat, Oswald, Roboto Mono, JetBrains Mono, Pacifico, Playfair Display, Bungee, VT323).

### 3. Hiệu ứng Neon, Viền & Nhấp nháy
- **Chế độ màu chữ**: Đơn sắc, Chuyển sắc 2 màu (Gradient), hoặc Cầu vồng chuyển động (Rainbow).
- **Bảng chọn màu chuyên sâu**: Bảng màu Neon gợi ý kết hợp trình chọn màu HSV 2D, thanh Hue và nhập mã HEX (`#RRGGBB`).
- **Phát sáng & Viền**: Tuỳ chỉnh độ phát sáng Neon / mờ (`0 – 28`), bật/tắt viền chữ kèm màu viền và độ dày (`1.0 – 12.0`).
- **Hiệu ứng nhấp nháy**: Hai kiểu nhấp nháy (**Nhấp nháy gắt** / **Sáng dịu nhịp**) với tần số tuỳ chỉnh (`1.0 – 6.0 Hz`).

### 4. Chế độ Ma trận Đèn LED (Pixel LED)
- Bật/tắt lớp lưới mô phỏng bóng đèn LED vật lý.
- **4 hình dạng bóng LED**: Tròn, Vuông, Bo góc, Kim cương.
- Tuỳ chỉnh kích thước hạt LED (`6 – 22 px`) và độ tương phản của lưới nền (`35% – 100%`).

### 5. Hình nền đa dạng
- **Màu đơn sắc**: Bảng màu tối tương phản cao hoặc màu tuỳ chọn.
- **9 Chủ đề động (Themes)**: Phân loại theo nhóm *Tất cả*, *Chung*, *Concert*, *Sinh nhật*, *Lễ hội* (`Neon Grid`, `Starfield`, `Aurora Wave`, `Laser Stage`, `Disco Spotlights`, `Birthday Confetti`, `Party Balloons`, `Winter Snow`, `Festive Lights`).
- **Ảnh & Video nền**: Chọn ảnh hoặc video lặp lại từ thư viện thiết bị kèm thanh làm tối nền (`0% – 85%`) giúp chữ luôn nổi bật.

### 6. Nhạc nền & Bảng vẽ tự do
- **Nhạc nền vòng lặp**: Tích hợp sẵn 4 bản nhạc (`Concert Pulse`, `Birthday Chime`, `Festive Bells`, `Neon Chill`), hỗ trợ chọn tệp âm thanh từ thiết bị (`.mp3`, `.wav`, `.m4a`, `.aac`, `.ogg`), nghe thử và chỉnh âm lượng.
- **Bảng vẽ LED**: Vẽ tay tự do hoặc vẽ hình khối (Đoạn thẳng, Hình chữ nhật, Hình tròn, Trái tim, Ngôi sao) trực tiếp trên bảng LED, hỗ trợ nét phát sáng neon, hoàn tác / làm lại (Undo / Redo) và xoá nhanh.

### 7. Trình phát Toàn màn hình
- Tự động chuyển sang chế độ toàn màn hình ngang (có thể xoay ngay trong trình phát) và giữ màn hình luôn sáng.
- **Vuốt dọc điều chỉnh độ sáng**: Vuốt lên/xuống trên màn hình để chỉnh độ sáng ứng dụng kèm thanh hiển thị phần trăm.
- **Khoá cảm ứng (Touch Lock)**: Chống chạm nhầm khi giơ cao ở sự kiện; nhấn giữ thanh thông báo để mở khoá lại.
- Thanh điều khiển nổi tự ẩn hỗ trợ tạm dừng, tắt/bật nhạc, xoay màn hình, phản chiếu nhanh và xuất MP4.

### 8. Lịch sử, Mẫu có sẵn & Xuất video MP4
- **Lịch sử & Mẫu sẵn**: Tự động lưu các bảng LED đã phát, hỗ trợ ghim bảng yêu thích, xoá mục lẻ hoặc xoá toàn bộ mục chưa ghim; đi kèm 8 mẫu thiết kế sẵn cho Concert, Sân bay, Sinh nhật, Giáng sinh, Khuyến mãi, Tiệc, Taxi, Tỏ tình.
- **Xuất video MP4**: Kết xuất hoạt ảnh bảng LED thành tệp `.mp4` ở độ phân giải **HD 720p (1280×720)** hoặc **SD 480p (854×480)** với thời lượng tự động khớp vòng lặp hoặc tuỳ chọn (`3s`, `5s`, `8s`, `10s`), lưu trực tiếp vào Thư viện ảnh hoặc chia sẻ qua menu hệ thống (hỗ trợ trên Android, iOS, macOS).
- **Song ngữ & Cài đặt**: Hỗ trợ chuyển đổi trực tiếp **Tiếng Việt** và **English**, cùng các tuỳ chọn giữ sáng màn hình, tự xoay ngang và tự lưu lịch sử.

---

## Cấu trúc thư mục

```text
lib/
├── main.dart                     # Điểm khởi chạy ứng dụng & khởi tạo dịch vụ
├── app.dart                      # Cấu hình MaterialApp, theme tối & đa ngôn ngữ
├── l10n/                         # Tệp bản địa hoá (app_vi.arb, app_en.arb)
├── domain/models/                # BannerConfig, BannerHistoryItem, AppSettings, PresetTemplates
├── data/
│   ├── repositories/             # BannerRepository (quản lý state lưu trữ & lịch sử)
│   └── services/                 # LocalStorage, Audio, Brightness, Wakelock, MediaPicker, VideoExport
└── ui/
    ├── core/                     # AppTheme, FontHelper, LedBannerPainter, LedBannerCanvas, ColorPicker
    └── features/
        ├── editor/               # Màn hình soạn thảo & 5 tab cấu hình
        ├── player/               # Màn hình phát LED toàn màn hình
        ├── draw/                 # Bảng vẽ tự do & hình khối
        ├── history/              # Lịch sử đã lưu & thư viện mẫu
        ├── export/               # Hộp thoại xuất video MP4
        └── settings/             # Cài đặt ngôn ngữ & hiển thị
assets/audio/                     # 4 tệp âm thanh .wav tích hợp sẵn
test/                             # Unit test & Widget test
```

---

## Cài đặt & Chạy dự án

```bash
# Cài đặt các thư viện phụ thuộc
flutter pub get

# Tạo mã nguồn đa ngôn ngữ từ các tệp .arb
flutter gen-l10n

# Chạy ứng dụng trên thiết bị hoặc trình giả lập
flutter run

# Kiểm tra phân tích tĩnh và chạy toàn bộ test
flutter analyze
flutter test

# Biên dịch gói APK debug cho Android
flutter build apk --debug
```
