# المساهمة في Lordlitor 🐊

شكراً لاهتمامك! كل مساهمة تُحدث فرقاً.

## 🚀 البدء

```bash
# 1. Fork ثم Clone
git clone https://github.com/YOUR_USERNAME/lordlitor.git
cd lordlitor

# 2. تثبيت الحزم
flutter pub get

# 3. إنشاء فرع
git checkout -b feat/your-feature

# 4. التطوير والاختبار
flutter run
flutter analyze

# 5. Commit & Push
git commit -m "feat: وصف التغيير"
git push origin feat/your-feature
```

ثم افتح **Pull Request** 🎉

---

## 📋 أنواع المساهمات

| النوع | الوصف |
|:-----:|:-----:|
| 🐛 **إصلاح خطأ** | افتح Issue أولاً مع خطوات إعادة الإنتاج |
| ✨ **ميزة جديدة** | ناقشها في Issue قبل التطوير |
| 📝 **أنماط أسئلة** | تأكد أن القسمة تنتج أعداد صحيحة |
| 🎨 **تحسين UI** | التزم بأسلوب Duolingo |
| 📖 **توثيق** | دائماً مرحب بها |

---

## 📏 معايير الكود

### الملفات والتسمية
- الملفات: `snake_case.dart`
- الكلاسات: `PascalCase`
- المتغيرات: `camelCase`

### رسائل Commit
```
feat: ميزة جديدة
fix: إصلاح خطأ
docs: تحديث توثيق
style: تنسيق (لا يغير المنطق)
refactor: إعادة هيكلة
perf: تحسين أداء
```

### قبل الإرسال
- [ ] `flutter analyze` بدون أخطاء
- [ ] اختبار على جهاز فعلي أو محاكي
- [ ] التزام بأسلوب الكود الموجود

---

## ⚡ إرشادات الأسئلة

عند إضافة أنماط أسئلة جديدة:

```dart
// ✅ صح: القسمة تنتج عدد صحيح
final divisor = 5, quotient = 20;
final dividend = divisor * quotient; // 100
// السؤال: 100 ÷ 5 = ?

// ❌ خطأ: نتيجة كسرية
// 7 ÷ 3 = 2.33... ← ممنوع!
```

- النتائج **أعداد صحيحة موجبة** دائماً
- **مستويات صعوبة** متوازنة (easy/medium/hard)
- **أرقام عشوائية** في كل مرة

---

شكراً لمساهمتك! 🙏
