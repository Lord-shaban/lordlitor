<p align="center">
  <img src="lib/image/logo_without_bg.png" alt="Lordlitor" width="150"/>
</p>

<h1 align="center">Lordlitor 🐊</h1>

<p align="center">
  <b>تدريب القدرات الذهنية والحساب السريع</b><br/>
  <i>Mental Abilities & Fast Math Training App</i>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=flat-square&logo=flutter&logoColor=white" alt="Flutter"/>
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?style=flat-square&logo=dart&logoColor=white" alt="Dart"/>
  <img src="https://img.shields.io/badge/Platform-Android%20|%20iOS-58CC02?style=flat-square" alt="Platform"/>
  <img src="https://img.shields.io/badge/License-MIT-yellow?style=flat-square" alt="License"/>
  <img src="https://img.shields.io/badge/Version-1.0.0-blue?style=flat-square" alt="Version"/>
</p>

---

## 🎯 حول التطبيق

**Lordlitor** تطبيق تعليمي تفاعلي مستوحى من [Duolingo](https://www.duolingo.com/) لتدريب القدرات الذهنية والرياضيات. مصمم لمساعدة الطلاب على التحضير لاختبارات القدرات من خلال تمارين متنوعة بأنماط مستخلصة من **68 سؤال امتحاني حقيقي**.

### لماذا Lordlitor؟

- 🧠 **أنماط حقيقية** — الأسئلة مبنية على تحليل أسئلة امتحانية فعلية
- 🎮 **تجربة ممتعة** — تصميم Duolingo-like يجعل التعلم إدمانياً
- 📊 **صعوبة ذكية** — يتكيف مع مستواك تلقائياً
- 🐊 **شخصية محبوبة** — التمساح اللطيف يرافقك في رحلتك

---

## ✨ الميزات

<table>
<tr>
<td width="50%">

### 📚 6 فئات تدريبية
- ✖️ الضرب (مع عمليات مركبة)
- ➕ الجمع (بأنماط امتحانية)
- ➖ الطرح (مع خدع حقيقية)
- ➗ القسمة (سلاسل عمليات)
- 🔢 المتتاليات العددية
- 🧠 الحساب الذهني (21 نمط!)

</td>
<td width="50%">

### 🎮 تجربة مستخدم غنية
- 🎨 تصميم Duolingo مع أزرار 3D
- 🔥 نظام كومبو (×1.5, ×2, ×3)
- 📈 نظام XP ومستويات وstreaks
- 📳 اهتزازات لمسية
- ✨ انيميشن سلسة
- 🐊 شخصية تفاعلية

</td>
</tr>
</table>

### 🧠 الحساب الذهني — 21 نمط سؤال

مبني على تحليل عميق لأسئلة الامتحانات الحقيقية:

```
العمليات المركبة (14 نمط):
  a×b+c  |  a×b×c  |  a×b+c×d  |  a×b-c×d  |  a×b÷c+d
  a×b+c÷d  |  a×b÷c×d  |  a+b×c×d  |  a÷b×c+d  |  a÷b×c
  a×b÷c-d  |  a÷b×c-d  |  a÷b÷c×d  |  a-b×c-d  ...وأكثر

مسائل لفظية:
  كسور (ثلث، نصف، ربع، خمس، سدس، ثمن...)
  تحويلات الوقت (ثواني ↔ دقائق ↔ ساعات ↔ أيام)
  وحدات التقويم (أشهر، عقود، عدّ الوحدات)
  هندسة (مجموع أضلاع الأشكال)
  نسب مئوية | عدد مفقود | ضعف/نصف | حاصل ضرب
```

### 🏋️ جدول الضرب (1-20)

- تدريب شامل لكل جدول
- **نظام إتقان**: الأسئلة الخاطئة تُعاد تلقائياً
- لا ينتهي التدريب حتى تجيب على الكل صح ✅

---

## 📊 نظام الصعوبة

| المستوى | الأرقام | العمليات | النتيجة | مثال |
|:-------:|:-------:|:--------:|:-------:|:----:|
| 🟢 سهل | 2-20 | 1-2 | <200 | `14 × 4 ÷ 2 + 18` |
| 🟡 متوسط | 10-100 | 2-3 | 100-600 | `9 × 6 + 12 × 4` |
| 🔴 صعب | 50-1000+ | 3-4+ | 500+ | `955 - 133 × 6 + 459` |

> 📌 **90%** من الأسئلة تكون من المستوى المُختار — لضمان تجربة عادلة.

---

## 🏗️ البنية

```
lordlitor/
├── lib/
│   ├── core/                  # ثيم + ثوابت
│   ├── models/                # نماذج البيانات
│   ├── services/              # محرك توليد الأسئلة
│   ├── screens/               # 6 شاشات
│   ├── widgets/               # عناصر مشتركة
│   ├── image/                 # أصول الصور
│   └── main.dart
├── .github/
│   ├── workflows/             # CI/CD
│   ├── ISSUE_TEMPLATE/        # قوالب Issues
│   └── PULL_REQUEST_TEMPLATE.md
├── README.md
├── CONTRIBUTING.md
├── CHANGELOG.md
├── CODE_OF_CONDUCT.md
└── LICENSE
```

---

## 🚀 البدء السريع

### المتطلبات
- [Flutter SDK](https://flutter.dev/docs/get-started/install) 3.x+
- Android Studio أو VS Code

### التشغيل

```bash
# استنساخ
git clone https://github.com/Lord-shaban/lordlitor.git
cd lordlitor

# تثبيت الحزم
flutter pub get

# تشغيل
flutter run
```

### البناء

```bash
# Android APK
flutter build apk --release

# Android Bundle
flutter build appbundle --release
```

### إعداد اختياري

```bash
# إنشاء Native Splash
dart run flutter_native_splash:create

# إنشاء أيقونات التطبيق
dart run flutter_launcher_icons
```

---

## 📦 الحزم

| الحزمة | الغرض |
|:------:|:-----:|
| `flutter_animate` | انيميشن |
| `google_fonts` | خط Cairo |
| `shared_preferences` | حفظ التقدم |
| `confetti` | تأثيرات احتفال |
| `percent_indicator` | مؤشرات التقدم |
| `fl_chart` | رسوم بيانية |
| `flutter_native_splash` | سبلاش أصلي |
| `flutter_launcher_icons` | أيقونات |

---

## 🛣️ خارطة الطريق

- [x] الإصدار الأول مع 6 فئات
- [x] 21 نمط حساب ذهني
- [x] نظام كومبو وXP
- [x] تصميم Duolingo-like
- [ ] وضع التحدي اليومي
- [ ] لوحة المتصدرين
- [ ] إضافة أنماط أسئلة جديدة
- [ ] دعم لغات متعددة
- [ ] وضع المسابقة (multiplayer)

---

## 🤝 المساهمة

المساهمات مرحب بها! اقرأ [CONTRIBUTING.md](CONTRIBUTING.md) للبدء.

## 📄 الرخصة

[MIT License](LICENSE) — استخدم، عدّل، وزّع بحرية.

---

<p align="center">
  <img src="lib/image/logo_happy.png" alt="Happy Lordlitor" width="80"/>
  <br/>
  <b>صُنع بـ ❤️ باستخدام Flutter</b>
</p>
