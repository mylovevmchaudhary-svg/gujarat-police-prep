import '../models/exam_type.dart';
import '../models/syllabus_model.dart';

class SyllabusData {
  static List<SyllabusSubject> getSyllabus(ExamType examType) {
    if (examType == ExamType.psi) {
      return _getPsiSyllabus();
    } else {
      return _getConstableSyllabus();
    }
  }

  static List<SyllabusSubject> _getConstableSyllabus() {
    return [
      SyllabusSubject(
        id: 'const_bandharan',
        title: 'Indian Constitution',
        titleGujarati: 'ભારતીય બંધારણ અને રાજ્યવ્યવસ્થા',
        iconName: 'gavel',
        totalMarksWeightage: 15,
        topics: [
          SyllabusTopic(
            id: 'c1',
            name: 'Preamble & Fundamental Rights',
            nameGujarati: 'આમુખ અને મૂળભૂત અધિકારો (કલમ 12 થી 35)',
            keyPoints: ['સમાનતાનો અધિકાર', 'સ્વતંત્રતાનો અધિકાર', 'બંધારણીય ઇલાજનો અધિકાર (Art 32)'],
          ),
          SyllabusTopic(
            id: 'c2',
            name: 'Directive Principles & Fundamental Duties',
            nameGujarati: 'માર્ગદર્શક સિદ્ધાંતો અને મૂળભૂત ફરજો (Art 51A)',
            keyPoints: ['રાજ્યનીતિના માર્ગદર્શક સિદ્ધાંતો', '11 મૂળભૂત ફરજો'],
          ),
          SyllabusTopic(
            id: 'c3',
            name: 'President, Governor & Parliament',
            nameGujarati: 'રાષ્ટ્રપતિ, રાજ્યપાલ, સંસદ અને વિધાનમંડળ',
            keyPoints: ['રાષ્ટ્રપતિની સત્તાઓ', 'રાજ્યપાલની નિમણૂક', 'લોકસભા અને રાજ્યસભાની રચના'],
          ),
          SyllabusTopic(
            id: 'c4',
            name: 'Judiciary & Panchayati Raj',
            nameGujarati: 'ન્યાયપાલિકા અને પંચાયતી રાજ (73મો & 74મો સુધારો)',
            keyPoints: ['સુપ્રીમ કોર્ટ', 'હાઇકોર્ટ', 'ત્રિસ્તરીય પંચાયતી રાજ'],
          ),
        ],
      ),
      SyllabusSubject(
        id: 'const_kaydo',
        title: 'Criminal Laws & Police Procedures',
        titleGujarati: 'કાયદો અને ફોજદારી કાર્યવાહી',
        iconName: 'security',
        totalMarksWeightage: 20,
        topics: [
          SyllabusTopic(
            id: 'k1',
            name: 'Indian Penal Code (IPC) / BNS Basics',
            nameGujarati: 'IPC / ભારતીય ન્યાય સંહિતાની મહત્વની કલમો',
            keyPoints: ['ગુનાહિત ષડયંત્ર', 'માનવ શરીર સામેના ગુના (હત્યા, ઇજા)', 'ચોરી, લૂંટ અને ધાડ'],
          ),
          SyllabusTopic(
            id: 'k2',
            name: 'Criminal Procedure Code (CrPC) / BNSS',
            nameGujarati: 'CrPC / ભારતીય નાગરિક સુરક્ષા સંહિતા',
            keyPoints: ['FIR દાખલ કરવાની પ્રક્રિયા (કલમ 154)', 'ધરપકડના નિયમો', 'જામીનલાયક અને બિનજામીનલાયક ગુના'],
          ),
          SyllabusTopic(
            id: 'k3',
            name: 'Indian Evidence Act / BSA',
            nameGujarati: 'ઇન્ડિયન એવિડન્સ એક્ટ / ભારતીય સાક્ષ્ય અધિનિયમ',
            keyPoints: ['મૌખિક અને દસ્તાવેજી પુરાવા', 'સાક્ષીઓની જુબાની', 'બર્ડન ઓફ પ્રૂફ'],
          ),
          SyllabusTopic(
            id: 'k4',
            name: 'Gujarat Police Act & Prohibition Act',
            nameGujarati: 'ગુજરાત પોલીસ એક્ટ અને દારૂબંધી અધિનિયમ',
            keyPoints: ['પોલીસ અધિકારીઓની ફરજો', 'જાહેર વ્યવસ્થા જાળવણી', 'દારૂબંધી કાયદાની જોગવાઈઓ'],
          ),
        ],
      ),
      SyllabusSubject(
        id: 'const_reasoning',
        title: 'Reasoning & Mental Ability',
        titleGujarati: 'તાર્કિક કસોટીઓ અને માનસિક ક્ષમતા',
        iconName: 'psychology',
        totalMarksWeightage: 20,
        topics: [
          SyllabusTopic(
            id: 'r1',
            name: 'Series & Coding-Decoding',
            nameGujarati: 'સંખ્યા / અક્ષર શ્રેણી અને કોડિંગ-ડિકોડિંગ',
            keyPoints: ['સંખ્યા શ્રેણી', 'આલ્ફાબેટ શ્રેણી', 'ચાઈનીઝ કોડિંગ'],
          ),
          SyllabusTopic(
            id: 'r2',
            name: 'Blood Relations & Direction Sense',
            nameGujarati: 'લોહીના સંબંધો અને દિશા-અંતર',
            keyPoints: ['કૌટુંબિક સંબંધોનું પૃથક્કરણ', 'દિશા અને ખૂણા ગણતરી'],
          ),
          SyllabusTopic(
            id: 'r3',
            name: 'Seating Arrangement & Syllogism',
            nameGujarati: 'બેઠક વ્યવસ્થા અને તર્ક આધારિત વિધાનો',
            keyPoints: ['ગોળાકાર અને લાઈન બેઠક વ્યવસ્થા', 'વેન આકૃતિઓ'],
          ),
        ],
      ),
      SyllabusSubject(
        id: 'const_gujarat_gk',
        title: 'Gujarat & India History, Geography & Culture',
        titleGujarati: 'ગુજરાત અને ભારતનો ઇતિહાસ, ભૂગોળ અને વારસો',
        iconName: 'terrain',
        totalMarksWeightage: 25,
        topics: [
          SyllabusTopic(
            id: 'g1',
            name: 'Gujarat History & Heritage',
            nameGujarati: 'ગુજરાતનો ઇતિહાસ અને સાંસ્કૃતિક વારસો',
            keyPoints: ['સિંધુ સભ્યતાના સ્થળો (લોથલ, ધોળાવીરા)', 'સોલંકી યુગ', 'ગુજરાતના મેળાઓ અને નૃત્યો'],
          ),
          SyllabusTopic(
            id: 'g2',
            name: 'Gujarat & India Geography',
            nameGujarati: 'ગુજરાત અને ભારતની ભૌગોલિક વિશેષતાઓ',
            keyPoints: ['નદીઓ અને બંધો', 'અભયારણ્યો અને રાષ્ટ્રીય ઉદ્યાનો', 'પર્વતમાળાઓ અને ખનીજો'],
          ),
          SyllabusTopic(
            id: 'g3',
            name: 'National Movement & Modern India',
            nameGujarati: 'ભારતનો સ્વાતંત્ર્ય સંગ્રામ અને મહાનુભાવો',
            keyPoints: ['1857નો વિપ્લવ', 'ગાંધીયુગ અને સત્યાગ્રહો', 'સરદાર વલ્લભભાઈ પટેલ'],
          ),
        ],
      ),
      SyllabusSubject(
        id: 'const_science_current',
        title: 'General Science & Current Affairs',
        titleGujarati: 'સામાન્ય વિજ્ઞાન અને તાજેતરના પ્રવાહો',
        iconName: 'biotech',
        totalMarksWeightage: 20,
        topics: [
          SyllabusTopic(
            id: 's1',
            name: 'General Science (Physics, Chem, Bio)',
            nameGujarati: 'રોજિંદા જીવનમાં સામાન્ય વિજ્ઞાન',
            keyPoints: ['માનવ શરીર અને રોગો', 'વિટામિન્સ અને પોષણ', 'વિજ્ઞાનના સામાન્ય નિયમો'],
          ),
          SyllabusTopic(
            id: 's2',
            name: 'National & State Current Affairs',
            nameGujarati: 'રાષ્ટ્રીય અને ગુજરાત રાજ્યના મહત્વના બનાવો',
            keyPoints: ['યોજનાઓ અને એવોર્ડ્સ', 'રમતગમત અને નિમણૂકો', 'સંરક્ષણ અને પોલીસ બાબતો'],
          ),
        ],
      ),
    ];
  }

  static List<SyllabusSubject> _getPsiSyllabus() {
    return [
      SyllabusSubject(
        id: 'psi_law',
        title: 'Criminal Law & IPC / CrPC / Evidence',
        titleGujarati: 'કાયદો (IPC, CrPC, પુરાવા અધિનિયમ & વિશેષ કાયદાઓ)',
        iconName: 'gavel',
        totalMarksWeightage: 100,
        topics: [
          SyllabusTopic(
            id: 'pl1',
            name: 'Indian Penal Code Detailed',
            nameGujarati: 'ભારતીય દંડ સંહિતા (IPC) ની તમામ મુખ્ય કલમો',
            keyPoints: ['કલમ 1 થી 511 નું વર્ગીકરણ', 'ખાનગી બચાવનો અધિકાર', 'માનવ શરીર અને મિલકત સામેના ગુનાઓ'],
          ),
          SyllabusTopic(
            id: 'pl2',
            name: 'CrPC - Investigation & Trial',
            nameGujarati: 'ફોજદારી કાર્યવાહી સંહિતા - તપાસ અને અદાલતી કાર્યવાહી',
            keyPoints: ['પોલીસ તપાસ અને પંચનામું', 'વોરંટ અને સમન્સ', 'ચાર્જશીટ રજૂ કરવાની પ્રક્રિયા'],
          ),
          SyllabusTopic(
            id: 'pl3',
            name: 'Special & Local Laws in Gujarat',
            nameGujarati: 'વિશેષ સ્થાનિક કાયદાઓ (POCSO, Atrocity, BP Act)',
            keyPoints: ['POCSO એક્ટ 2012', 'SC/ST અત્યાચાર નિવારણ ધારો', 'ભ્રષ્ટાચાર નિવારણ અધિનિયમ'],
          ),
        ],
      ),
      SyllabusSubject(
        id: 'psi_gujarati',
        title: 'Gujarati Language & Grammar',
        titleGujarati: 'ગુજરાતી ભાષા, વ્યાકરણ અને સાહિત્ય',
        iconName: 'menu_book',
        totalMarksWeightage: 100,
        topics: [
          SyllabusTopic(
            id: 'pg1',
            name: 'Gujarati Grammar (Vyakaran)',
            nameGujarati: 'સમાસ, સંધિ, અલંકાર, છંદ, જોડણી',
            keyPoints: ['શબ્દ સમૂહ માટે એક શબ્દ', 'રૂઢિપ્રયોગો અને કહેવતો', 'વાક્ય પરિવર્તન (કર્તરિ-કર્મણિ)'],
          ),
          SyllabusTopic(
            id: 'pg2',
            name: 'Gujarati Literature (Sahitya)',
            nameGujarati: 'મહત્વના સાહિત્યકારો, કૃતિઓ અને તખલ્લુસ',
            keyPoints: ['નરસિંહ મહેતા, મીરાંબાઈ, નર્મદ', 'જ્ઞાનપીઠ પુરસ્કાર વિજેતાઓ', 'મુખ્ય સાહિત્યિક સંસ્થાઓ'],
          ),
        ],
      ),
      SyllabusSubject(
        id: 'psi_english',
        title: 'English Grammar & Vocabulary',
        titleGujarati: 'અંગ્રેજી વ્યાકરણ અને વોકેબ્યુલરી',
        iconName: 'translate',
        totalMarksWeightage: 100,
        topics: [
          SyllabusTopic(
            id: 'pe1',
            name: 'Tenses, Active-Passive & Direct-Indirect',
            nameGujarati: 'કાળ, એક્ટિવ-પેસિવ વોઈસ અને ડાયરેક્ટ-ઇનડાયરેક્ટ',
            keyPoints: ['Subject-Verb Agreement', 'Prepositions & Conjunctions', 'Model Auxiliaries'],
          ),
          SyllabusTopic(
            id: 'pe2',
            name: 'Vocabulary & Comprehension',
            nameGujarati: 'Synonyms, Antonyms, Idioms & Phrases',
            keyPoints: ['One-word Substitution', 'Error Spotting', 'Reading Comprehension'],
          ),
        ],
      ),
      SyllabusSubject(
        id: 'psi_gs',
        title: 'General Studies & Reasoning',
        titleGujarati: 'જનરલ સ્ટડીઝ, બંધારણ અને તાર્કિક ક્ષમતા',
        iconName: 'analytics',
        totalMarksWeightage: 100,
        topics: [
          SyllabusTopic(
            id: 'pgs1',
            name: 'Constitution & Administration',
            nameGujarati: 'ભારતીય બંધારણ અને વહીવટી તંત્ર',
            keyPoints: ['મૂળભૂત હકો અને ફરજો', 'બંધારણીય સંસ્થાઓ (UPSC, ECI, CAG)', 'કટોકટીની જોગવાઈઓ'],
          ),
          SyllabusTopic(
            id: 'pgs2',
            name: 'Quantitative Aptitude & Reasoning',
            nameGujarati: 'ગણિત અને તાર્કિક ક્ષમતા (D.I. & Mental Ability)',
            keyPoints: ['ટકાવારી, નફો-ખોટ, સાદું વ્યાજ', 'સમય, અંતર અને ઝડપ', 'ડેટા ઇન્ટરપ્રિટેશન'],
          ),
        ],
      ),
    ];
  }
}
