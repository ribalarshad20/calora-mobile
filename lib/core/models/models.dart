class AuthUser {
  AuthUser({
    required this.id,
    required this.email,
    required this.name,
    required this.onboardingComplete,
  });

  final String id;
  final String email;
  final String name;
  final bool onboardingComplete;

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        id: json['id'] as String,
        email: json['email'] as String,
        name: json['name'] as String,
        onboardingComplete: json['onboardingComplete'] as bool? ?? false,
      );
}

class Profile {
  Profile({
    required this.sex,
    required this.age,
    required this.heightCm,
    required this.weightKg,
    required this.goal,
    required this.activityLevel,
    required this.bmr,
    required this.tdee,
    required this.calorieTarget,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.waterGoalMl,
    required this.theme,
  });

  final String sex;
  final int age;
  final double heightCm;
  final double weightKg;
  final String goal;
  final String activityLevel;
  final int bmr;
  final int tdee;
  final int calorieTarget;
  final int proteinG;
  final int carbsG;
  final int fatG;
  final int waterGoalMl;
  final String theme;

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        sex: json['sex'] as String,
        age: (json['age'] as num).toInt(),
        heightCm: (json['heightCm'] as num).toDouble(),
        weightKg: (json['weightKg'] as num).toDouble(),
        goal: json['goal'] as String,
        activityLevel: json['activityLevel'] as String,
        bmr: (json['bmr'] as num).toInt(),
        tdee: (json['tdee'] as num).toInt(),
        calorieTarget: (json['calorieTarget'] as num).toInt(),
        proteinG: (json['proteinG'] as num).toInt(),
        carbsG: (json['carbsG'] as num).toInt(),
        fatG: (json['fatG'] as num).toInt(),
        waterGoalMl: (json['waterGoalMl'] as num?)?.toInt() ?? 2500,
        theme: json['theme'] as String? ?? 'sage_mist',
      );
}

class Macros {
  Macros({
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
  });

  final double calories;
  final double proteinG;
  final double carbsG;
  final double fatG;

  factory Macros.fromJson(Map<String, dynamic> json) => Macros(
        calories: (json['calories'] as num).toDouble(),
        proteinG: (json['proteinG'] as num).toDouble(),
        carbsG: (json['carbsG'] as num).toDouble(),
        fatG: (json['fatG'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'calories': calories,
        'proteinG': proteinG,
        'carbsG': carbsG,
        'fatG': fatG,
      };
}

class DiaryEntry {
  DiaryEntry({
    required this.id,
    required this.date,
    required this.mealType,
    required this.name,
    required this.macros,
    this.brand = '',
    this.source = 'manual',
  });

  final String id;
  final String date;
  final String mealType;
  final String name;
  final String brand;
  final Macros macros;
  final String source;

  factory DiaryEntry.fromJson(Map<String, dynamic> json) => DiaryEntry(
        id: json['id'] as String,
        date: json['date'] as String,
        mealType: json['mealType'] as String,
        name: json['name'] as String,
        brand: json['brand'] as String? ?? '',
        macros: Macros.fromJson(json['macros'] as Map<String, dynamic>),
        source: json['source'] as String? ?? 'manual',
      );
}

class DaySummary {
  DaySummary({
    required this.date,
    required this.calorieTarget,
    required this.proteinTarget,
    required this.carbsTarget,
    required this.fatTarget,
    required this.waterGoalMl,
    required this.consumed,
    required this.burnedTotal,
    required this.remaining,
    required this.steps,
    required this.waterMl,
    this.stepsSource,
  });

  final String date;
  final int calorieTarget;
  final int proteinTarget;
  final int carbsTarget;
  final int fatTarget;
  final int waterGoalMl;
  final Macros consumed;
  final int burnedTotal;
  final int remaining;
  final int steps;
  final int waterMl;
  final String? stepsSource;

  factory DaySummary.fromJson(Map<String, dynamic> json) => DaySummary(
        date: json['date'] as String,
        calorieTarget: (json['calorieTarget'] as num).toInt(),
        proteinTarget: (json['proteinTarget'] as num).toInt(),
        carbsTarget: (json['carbsTarget'] as num).toInt(),
        fatTarget: (json['fatTarget'] as num).toInt(),
        waterGoalMl: (json['waterGoalMl'] as num).toInt(),
        consumed: Macros.fromJson(json['consumed'] as Map<String, dynamic>),
        burnedTotal: (json['burned']['total'] as num).toInt(),
        remaining: (json['remaining'] as num).toInt(),
        steps: (json['steps'] as num).toInt(),
        waterMl: (json['waterMl'] as num).toInt(),
        stepsSource: json['stepsSource'] as String?,
      );
}

class FoodItem {
  FoodItem({
    required this.name,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    this.brand = '',
    this.barcode,
    this.id,
    this.servingGrams,
  });

  final String? id;
  final String name;
  final String brand;
  final String? barcode;
  final double calories;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final double? servingGrams;

  factory FoodItem.fromOffJson(Map<String, dynamic> json) => FoodItem(
        name: json['name'] as String,
        brand: json['brand'] as String? ?? '',
        barcode: json['barcode'] as String?,
        calories: (json['calories'] as num).toDouble(),
        proteinG: (json['proteinG'] as num).toDouble(),
        carbsG: (json['carbsG'] as num).toDouble(),
        fatG: (json['fatG'] as num).toDouble(),
        servingGrams: (json['servingGrams'] as num?)?.toDouble(),
      );

  factory FoodItem.fromCustomJson(Map<String, dynamic> json) => FoodItem(
        id: json['id'] as String?,
        name: json['name'] as String,
        brand: json['brand'] as String? ?? '',
        calories: (json['calories'] as num).toDouble(),
        proteinG: (json['proteinG'] as num).toDouble(),
        carbsG: (json['carbsG'] as num).toDouble(),
        fatG: (json['fatG'] as num).toDouble(),
        servingGrams: (json['servingGrams'] as num?)?.toDouble(),
      );
}

class AiMealItem {
  AiMealItem({
    required this.name,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    this.grams,
    this.confidence,
  });

  final String name;
  final double calories;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final double? grams;
  final double? confidence;

  factory AiMealItem.fromJson(Map<String, dynamic> json) => AiMealItem(
        name: json['name'] as String,
        calories: (json['calories'] as num).toDouble(),
        proteinG: (json['proteinG'] as num).toDouble(),
        carbsG: (json['carbsG'] as num).toDouble(),
        fatG: (json['fatG'] as num).toDouble(),
        grams: (json['grams'] as num?)?.toDouble(),
        confidence: (json['confidence'] as num?)?.toDouble(),
      );
}
