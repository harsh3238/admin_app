class TheSession {
  int sessionId;
  String sessionName;
  int defaultSession;
  int activeSession;


  TheSession(this.sessionId, this.sessionName, this.defaultSession, this.activeSession);

  factory TheSession.fromJson(Map<String, dynamic> parsedJson) {
    return TheSession(parsedJson['session_id'], parsedJson['session_name'],
        parsedJson['default_session'], parsedJson['active_session']);
  }
}
