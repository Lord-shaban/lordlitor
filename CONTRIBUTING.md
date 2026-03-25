# المساهمة في Lordlitor 🐊

شكراً لاهتمامك بالمساهمة! كل مساهمة تُحدث فرقاً.

---

## 🚀 البدء السريع

```bash
# 1. Fork المشروع من GitHub ثم Clone
git clone https://github.com/YOUR_USERNAME/lordlitor.git
cd lordlitor

# 2. تثبيت الحزم
flutter pub get

# 3. إنشاء فرع جديد
git checkout -b feat/your-feature

# 4. التطوير والتحقق
flutter run
flutter analyze

# 5. Commit & Push
git commit -m "feat: وصف التغيير"
git push origin feat/your-feature
```

ثم افتح **Pull Request** من GitHub 🎉

---

## 📋 أنواع المساهمات المرحب بها

| النوع | الوصف | كيف تبدأ |
|:-----:|:-----:|:--------:|
| 🐛 إصلاح خطأ | إصلاح مشاكل موجودة | افتح Issue أولاً |
| ✨ ميزة جديدة | إضافة وظائف جديدة | ناقشها في Issue |
| 📝 أنماط أسئلة | إضافة أنماط رياضية | راجع الإرشادات أدناه |
| 🎨 تحسين UI | تحسين التصميم والتجربة | التزم بأسلوب Duolingo |
| 📖 توثيق | تحسين الملفات والتعليقات | دائماً مرحب بها |
| 🌐 ترجمة | إضافة لغات جديدة | تواصل معنا أولاً |

---

## 📏 معايير الكود

### التسمية
| النوع | التنسيق | مثال |
|:-----:|:-------:|:----:|
| ملفات | `snake_case.dart` | `quiz_screen.dart` |
| كلاسات | `PascalCase` | `QuizScreen` |
| متغيرات | `camelCase` | `totalScore` |
| ثوابت | `camelCase` | `xpPerLevel` |

### رسائل Commit (Conventional Commits)
```
feat: ميزة جديدة          fix: إصلاح خطأ
docs: تحديث توثيق          style: تنسيق (لا يغير المنطق)
refactor: إعادة هيكلة      perf: تحسين أداء
test: إضافة اختبارات       chore: مهام صيانة
```

### قبل إرسال PR
- [ ] `flutter analyze` بدون أخطاء
- [ ] اختبار على جهاز فعلي أو محاكي
- [ ] التزام بأسلوب الكود الموجود
- [ ] تحديث التوثيق إذا لزم الأمر
- [ ] رسائل commit واضحة ومرتبة

---

## ⚡ إرشادات الأسئلة

عند إضافة أنماط أسئلة جديدة، التزم بالقواعد التالية:

### القواعد الأساسية

```dart
// ✅ صح: القسمة تنتج عدد صحيح
final divisor = 5, quotient = 20;
final dividend = divisor * quotient; // 100
// السؤال: 100 ÷ 5 = ?  →  الإجابة: 20 ✓

// ❌ خطأ: نتيجة كسرية
// 7 ÷ 3 = 2.33... ← ممنوع!
```

### معايير الأسئلة
- ✅ النتائج **أعداد صحيحة موجبة** دائماً
- ✅ **3 مستويات صعوبة** (easy / medium / hard) لكل نمط
- ✅ **أرقام عشوائية** تتغير كل مرة
- ✅ التحقق من أن السؤال ليس بسيطاً جداً أو مستحيلاً
- ❌ لا أعداد سالبة في النتائج
- ❌ لا كسور في الإجابات

### البنية الأساسية لنمط جديد

```dart
Question _createNewPattern(Difficulty d) {
  // 1. تحديد نطاق الأرقام حسب الصعوبة
  int a, b;
  switch (d) {
    case Difficulty.easy: a = _r([2, 10]); b = _r([2, 5]);
    case Difficulty.medium: a = _r([10, 50]); b = _r([5, 20]);
    case Difficulty.hard: a = _r([20, 100]); b = _r([10, 50]);
  }
  
  // 2. حساب الإجابة
  final answer = a * b;
  
  // 3. إنشاء السؤال
  return Question(
    questionText: '$a × $b = ؟',
    correctAnswer: '$answer',
    type: QuestionType.multiplication,
    difficulty: d,
    weight: _wt(d),
    bonusXp: _bxp(d),
  );
}
```

---

## 🏗️ هيكل المشروع

```
lib/
├── core/           # الثوابت والثيم — عدّل أولاً عند إضافة فئة جديدة
├── models/         # نماذج البيانات — أضف enum جديد هنا
├── services/       # محرك الأسئلة والتخزين — أضف أنماط هنا
├── screens/        # الشاشات — عادةً لا تحتاج تعديل للأنماط
└── widgets/        # عناصر واجهة مشتركة
```

---

شكراً لمساهمتك! 🙏🐊
