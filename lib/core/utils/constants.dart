class AppConstants {
  static const String baseUrl = 'http://192.168.1.100:8000/api';

  // Cow status
  static const String statusActive = 'active';
  static const String statusDry = 'dry';
  static const String statusPregnant = 'pregnant';
  static const String statusSold = 'sold';
  static const String statusDeceased = 'deceased';

  // Health record types
  static const String healthTreatment = 'treatment';
  static const String healthVaccination = 'vaccination';
  static const String healthDeworming = 'deworming';
  static const String healthOther = 'other';

  // Breeding record types
  static const String breedingHeat = 'heat';
  static const String breedingService = 'service';
  static const String breedingPregnancyCheck = 'pregnancy_check';
  static const String breedingCalving = 'calving';

  // Expense categories
  static const String expenseFeed = 'feed';
  static const String expenseMedicine = 'medicine';
  static const String expenseVet = 'vet';
  static const String expenseLabour = 'labour';
  static const String expenseOther = 'other';

  // Cow genders
  static const String genderFemale = 'female';
  static const String genderMale = 'male';

  // Cow breeds
  static const List<String> breeds = [
    'Friesian',
    'Jersey',
    'Ayrshire',
    'Guernsey',
    'Brown Swiss',
    'Holstein',
    'Zebu',
    'Crossbreed',
    'Other',
  ];

  // Pregnancy results
  static const String pregnantYes = 'pregnant';
  static const String pregnantNo = 'open';
  static const String pregnantUncertain = 'uncertain';
}
