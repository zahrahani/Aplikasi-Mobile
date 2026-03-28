import 'questions.dart';

class QuizBrain {
  int _questionNumber = 0;

  List<Question> _questionBank = [
    Question(
      q: "Jika perut sudah bunyi karena lapar, kita bisa mengubahnya ke 'mode getar' agar tidak berisik.", 
      a: false),
    Question(
      q: "Alasan lari pagi sangat melelahkan adalah karena makan mi instan pakai telur dan nasi tadi malam.", 
      a: true),
    Question(
      q: "Darah itu warnanya pink fanta", 
      a: false),
  ];

  void nextQuestion() {
    if (_questionNumber < _questionBank.length - 1) {
      _questionNumber++;
    }
    print(_questionNumber);
    print(_questionBank.length);
  }

  void reset() {
    _questionNumber = 0;
  }

  String getQuestionText() {
    return _questionBank[_questionNumber].questionText;
  }

  bool getCorrectAnswer() {
    return _questionBank[_questionNumber].questionAnswer;
  }

  bool isFinished() {
    return _questionNumber >= _questionBank.length - 1;
  }
}
