import '../models/quiz_model.dart';

class CsvQuestionParser {
  /// Sample CSV format for 200 questions bulk upload
  static String getSampleCsvTemplate() {
    return '''Question,OptionA,OptionB,OptionC,OptionD,OptionE,CorrectOption,Subject,Explanation
"IPC ની કઈ કલમ હેઠળ ચોરીની વ્યાખ્યા છે?","કલમ 378","કલમ 379","કલમ 390","કલમ 392","પ્રયાસ કરેલ નથી",A,"કાયદો","કલમ 378 માં વ્યાખ્યા અને 379 માં સજા છે."
"બંધારણના કયા અનુચ્છેદ મુજબ કાયદા સમક્ષ સમાનતા છે?","અનુચ્છેદ 14","અનુચ્છેદ 19","અનુચ્છેદ 21","અનુચ્છેદ 32","પ્રયાસ કરેલ નથી",A,"બંધારણ","અનુચ્છેદ 14 કાયદા સમક્ષ સમાનતા આપે છે."
"લોથલ કયા જિલ્લામાં આવેલું છે?","કચ્છ","અમદાવાદ","જામનગર","રાજકોટ","પ્રયાસ કરેલ નથી",B,"ઇતિહાસ","લોથલ અમદાવાદ જિલ્લાના ધોળકા તાલુકામાં છે."
''';
  }

  /// Parses CSV or Tab-separated text into a list of Question objects
  static List<Question> parseCsv(String csvText, {String subjectPrefix = ''}) {
    final List<Question> questions = [];
    final lines = csvText.split('\n');

    int qIndex = 1;
    for (var line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('Question,')) {
        continue; // Skip header or empty line
      }

      // Simple CSV splitter handling quoted values
      final parts = _parseCsvLine(trimmed);
      if (parts.length >= 7) {
        final qText = parts[0].trim();
        final optA = parts[1].trim();
        final optB = parts[2].trim();
        final optC = parts[3].trim();
        final optD = parts[4].trim();
        final optE = parts.length > 5 && parts[5].isNotEmpty
            ? parts[5].trim()
            : 'પ્રયાસ કરેલ નથી (Not Attempted)';

        final correctOptChar = (parts.length > 6 ? parts[6].trim().toUpperCase() : 'A');
        int correctIndex = 0;
        if (correctOptChar == 'B') correctIndex = 1;
        if (correctOptChar == 'C') correctIndex = 2;
        if (correctOptChar == 'D') correctIndex = 3;
        if (correctOptChar == 'E') correctIndex = 4;

        final subject = parts.length > 7 && parts[7].isNotEmpty
            ? parts[7].trim()
            : (subjectPrefix.isNotEmpty ? subjectPrefix : 'જનરલ સ્ટડીઝ');

        final explanation = parts.length > 8 && parts[8].isNotEmpty
            ? parts[8].trim()
            : 'સત્તાવાર ઉત્તર કૂંચી મુજબ સાચો વિકલ્પ.';

        questions.add(
          Question(
            id: 'csv_q_$qIndex',
            subject: subject,
            questionText: 'પ્રશ્ન $qIndex. $qText',
            options: [
              'A. $optA',
              'B. $optB',
              'C. $optC',
              'D. $optD',
              'E. $optE',
            ],
            correctOptionIndex: correctIndex,
            explanation: explanation,
          ),
        );
        qIndex++;
      }
    }
    return questions;
  }

  static List<String> _parseCsvLine(String line) {
    final List<String> result = [];
    final StringBuffer current = StringBuffer();
    bool inQuotes = false;

    for (int i = 0; i < line.length; i++) {
      final char = line[i];
      if (char == '"') {
        inQuotes = !inQuotes;
      } else if (char == ',' && !inQuotes) {
        result.add(current.toString());
        current.clear();
      } else {
        current.write(char);
      }
    }
    result.add(current.toString());
    return result;
  }
}
