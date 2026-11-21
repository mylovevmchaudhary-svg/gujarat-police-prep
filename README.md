# 👮‍♂️ Gujarat Police (PSI & Constable) Exam Preparation App

ગુજરાત પોલીસ **કોન્સ્ટેબલ (LRD)** અને **પોલીસ સબ ઇન્સ્પેક્ટર (PSI)** પરીક્ષાની તૈયારી કરતા વિદ્યાર્થીઓ માટે ખાસ તૈયાર કરાયેલ Flutter મોબાઇલ એપ્લિકેશન.

---

## 🌟 મુખ્ય વિશેષતાઓ (Key Features)

1. **સંપૂર્ણ સિલેબસ ટ્રેકર (Syllabus Tracker & Checklist)**:
   - PSI અને કોન્સ્ટેબલ બંને માટે વિષયવાર અને મુદ્દાવાર સંપૂર્ણ અભ્યાસક્રમ.
   - કાયદો (IPC, CrPC, પુરાવા અધિનિયમ, ગુજરાત પોલીસ એક્ટ).
   - ભારતીય બંધારણ, ગુજરાતનો ઇતિહાસ, ભૂગોળ, સાહિત્ય, સામાન્ય વિજ્ઞાન, રીઝનિંગ અને ગણિત.
   - વિદ્યાર્થીઓ દરેક ટોપિક વાંચીને "પૂર્ણ" માર્ક કરી શકે છે અને લાઇવ પ્રોગ્રેસ બાર જોઈ શકે છે.

2. **ઓનલાઇન મોક ટેસ્ટ એન્જિન (Real Exam Simulation)**:
   - ટાઈમર આધારિત મોક ટેસ્ટ.
   - પ્રશ્ન પેલેટ (Question Palette) જેનાથી કોઈપણ પ્રશ્ન પર સીધા પહોંચી શકાય.
   - **ઓપ્શન E (Not Attempted)**: GSSSB / GPSB ના નિયમ મુજબ જો જવાબ ન આવડતો હોય તો વિકલ્પ 'E' પસંદ કરવાનો વિકલ્પ.
   - બુકમાર્ક સુવિધા: અઘરા પ્રશ્નોને રિવિઝન માટે સાચવો.

3. **પરિણામ અને એનાલિટિક્સ (Detailed Score Card)**:
   - **નેગેટિવ માર્કિંગ ગણતરી**: સાચા ઉત્તર દીઠ +1.0 ગુણ, ખોટા ઉત્તર દીઠ -0.25 ગુણ, અને 'E' અથવા છોડેલ પ્રશ્નો માટે 0.0 ગુણ.
   - એક્યુરસી (Accuracy %) અને સમય વિશ્લેષણ.
   - **વિશેષ સમજૂતી (Detailed Explanation)** સાથે સંપૂર્ણ ઉત્તર કૂંચી.

4. **સાચવેલા પ્રશ્નો (Bookmarks Section)**:
   - પરીક્ષાના છેલ્લા દિવસોમાં ઝડપી રિવિઝન માટે.

---

## 📂 પ્રોજેક્ટ માળખું (Project Structure)

```
gujarat_police_prep/
├── lib/
│   ├── data/
│   │   ├── mock_questions_data.dart    # મોક ટેસ્ટ પ્રશ્ન બેંક
│   │   └── syllabus_data.dart          # PSI અને કોન્સ્ટેબલ સિલેબસ
│   ├── models/
│   │   ├── exam_type.dart              # PSI vs Constable એન્મ
│   │   ├── quiz_model.dart             # ક્વિઝ અને સ્કોર મોડલ
│   │   └── syllabus_model.dart         # વિષય અને ટોપિક મોડલ
│   ├── screens/
│   │   ├── bookmarks_screen.dart       # બુકમાર્ક પ્રશ્નો સ્ક્રીન
│   │   ├── home_screen.dart            # ડેશબોર્ડ સ્ક્રીન
│   │   ├── quiz_result_screen.dart     # સ્કોર કાર્ડ અને ઉત્તર કૂંચી
│   │   ├── quiz_screen.dart            # પરીક્ષા ઇન્ટરફેસ (ટાઈમર સાથે)
│   │   ├── syllabus_screen.dart        # સિલેબસ ચેકલિસ્ટ
│   │   └── test_series_screen.dart     # મોક ટેસ્ટ લિસ્ટિંગ
│   └── main.dart                       # એપ એન્ટ્રી પોઈન્ટ
└── pubspec.yaml
```

---

## 🚀 એપ કેવી રીતે ચલાવવી (How to Run)

1. Flutter SDK ને `C:\src\flutter` માં એક્સટ્રેક્ટ કરો.
2. ટર્મિનલમાં પ્રોજેક્ટ ફોલ્ડરમાં જાઓ:
   ```bash
   cd "C:\Users\Bluraj India\.gemini\antigravity\scratch\gujarat_police_prep"
   ```
3. ડિપેન્ડન્સી ડાઉનલોડ કરો:
   ```bash
   flutter pub get
   ```
4. એપ રન કરો (Android Emulator, Chrome, અથવા જોડાયેલ ફોન પર):
   ```bash
   flutter run
   ```
