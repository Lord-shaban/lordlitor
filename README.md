<p align="center">
  <img src="lib/image/logo_without_bg.png" alt="Lordlitor Logo" width="180"/>
</p>

<h1 align="center">🐊 Lordlitor</h1>

<p align="center">
  <strong>تدريب القدرات الذهنية | Mental Abilities Training App</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter" alt="Flutter"/>
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart" alt="Dart"/>
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-green?style=for-the-badge" alt="Platform"/>
  <img src="https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge" alt="License"/>
</p>

<p align="center">
  تطبيق تفاعلي مستوحى من Duolingo لتدريب القدرات الذهنية والرياضيات، مصمم بأسلوب ممتع وجذاب مع شخصية التمساح اللطيف 🐊
</p>

---

## 📱 نظرة عامة

**Lordlitor** هو تطبيق تعليمي تفاعلي يهدف إلى تطوير المهارات الحسابية والقدرات الذهنية من خلال تمارين متنوعة وتحديات بمستويات صعوبة مختلفة. التطبيق مستوحى من تجربة **Duolingo** في التصميم والتفاعل.

## ✨ الميزات الرئيسية

### 📊 أنواع التمارين
| النوع | الوصف | المستويات |
|-------|-------|-----------|
| ✖️ **الضرب** | جداول الضرب + عمليات متعددة | سهل • متوسط • صعب |
| ➕ **الجمع** | جمع أعداد مع عمليات مركبة | سهل • متوسط • صعب |
| ➖ **الطرح** | طرح مع أنماط امتحانية حقيقية | سهل • متوسط • صعب |
| ➗ **القسمة** | قسمة مع سلاسل عمليات | سهل • متوسط • صعب |
| 🔢 **المتتاليات** | حسابية، هندسية، تربيعية | سهل • متوسط • صعب |
| 🧠 **الحساب الذهني** | 21 نمط مختلف من الأسئلة | سهل • متوسط • صعب |

### 🧠 أنماط الحساب الذهني
- **العمليات المركبة**: `a×b+c`, `a×b÷c+d`, `a÷b×c-d` (21 نمط)
- **الكسور اللفظية**: ثلث، نصف، ربع، خمس، سدس، ثمن...
- **تحويلات الوقت**: ثواني ↔ دقائق ↔ ساعات ↔ أيام
- **التقويم والوحدات**: أشهر، عقود، عدّ الوحدات
- **الهندسة**: مجموع أضلاع الأشكال
- **النسب المئوية**: حسابات النسبة
- **العدد المفقود**: إيجاد المجهول
- **الضعف والنصف**: مضاعفة وتنصيف
- **حاصل الضرب المباشر**: ضرب بصيغة لفظية

### 🎮 تجربة المستخدم
- 🎨 **تصميم مستوحى من Duolingo** مع أزرار ثلاثية الأبعاد
- 🐊 **شخصية التمساح** المرحة مع تعابير متعددة
- 📈 **نظام تقدم متكامل** (XP, مستويات, streaks)
- 🔥 **نظام كومبو** مع مضاعفات النقاط
- 📳 **اهتزازات لمسية** (Haptic Feedback) على التفاعل
- ✨ **انيميشن سلسة** على جميع العناصر
- 🎯 **صعوبة تكيفية** حسب مستوى اللاعب

### 🏋️ جدول الضرب
- تدريب شامل على جداول الضرب من **1 إلى 20**
- نظام **إعادة المحاولة** - الأسئلة الخاطئة تُعاد حتى الإتقان
- تتبع التقدم لكل جدول

## 🏗️ البنية التقنية

```
lib/
├── core/
│   ├── app_theme.dart         # نظام الألوان والثيم
│   └── constants.dart         # الثوابت العامة
├── models/
│   └── question_model.dart    # نماذج البيانات
├── services/
│   └── question_generator.dart # محرك توليد الأسئلة
├── screens/
│   ├── splash_screen.dart     # شاشة البداية
│   ├── home_screen.dart       # الشاشة الرئيسية
│   ├── categories_screen.dart # شاشة الفئات
│   ├── quiz_screen.dart       # شاشة الاختبار
│   ├── result_screen.dart     # شاشة النتائج
│   └── multiplication_table_screen.dart
├── widgets/
│   └── duo_button.dart        # أزرار ثلاثية الأبعاد
├── image/
│   ├── logo.jpg               # اللوجو الأصلي
│   ├── logo_without_bg.png    # اللوجو بخلفية شفافة
│   └── logo_happy.png         # التمساح السعيد
└── main.dart                  # نقطة البداية
```

## 🚀 التثبيت والتشغيل

### المتطلبات
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.x أو أحدث)
- [Dart SDK](https://dart.dev/get-dart) (3.x أو أحدث)
- Android Studio / VS Code
- Android SDK أو Xcode (للتشغيل على المحاكي)

### خطوات التشغيل

```bash
# 1. استنساخ المشروع
git clone https://github.com/YOUR_USERNAME/lordlitor.git
cd lordlitor

# 2. تثبيت الحزم
flutter pub get

# 3. إنشاء Native Splash Screen
dart run flutter_native_splash:create

# 4. إنشاء أيقونات التطبيق
dart run flutter_launcher_icons

# 5. تشغيل التطبيق
flutter run
```

### البناء للإنتاج

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release
```

## 📦 الحزم المستخدمة

| الحزمة | الاستخدام |
|--------|-----------|
| `google_fonts` | خطوط عربية احترافية (Cairo) |
| `flutter_animate` | انيميشن سلسة ومتقدمة |
| `shared_preferences` | حفظ التقدم محلياً |
| `confetti` | تأثيرات الاحتفال |
| `percent_indicator` | مؤشرات التقدم الدائرية |
| `fl_chart` | رسوم بيانية للإحصائيات |
| `flutter_native_splash` | شاشة بداية أصلية |
| `flutter_launcher_icons` | أيقونات التطبيق |

## 📊 نظام الصعوبة الذكي

يعتمد التطبيق على تحليل **68 سؤال امتحاني حقيقي** لتحديد مستويات الصعوبة:

| المستوى | حجم الأرقام | عدد العمليات | نطاق النتائج |
|---------|-------------|--------------|--------------|
| 🟢 سهل | 2-20 | 1-2 | < 200 |
| 🟡 متوسط | 10-100 | 2-3 | 100-600 |
| 🔴 صعب | 50-1000+ | 3-4+ | 500-10,000 |

## 🤝 المساهمة

المساهمات مرحب بها! يرجى قراءة [دليل المساهمة](CONTRIBUTING.md) قبل البدء.

## 📄 الرخصة

هذا المشروع مرخص تحت [رخصة MIT](LICENSE).

## 📬 التواصل

إذا كانت لديك أسئلة أو اقتراحات، لا تتردد في فتح [Issue](../../issues) جديدة.

---

<p align="center">
  صُنع بـ ❤️ باستخدام Flutter
</p>
