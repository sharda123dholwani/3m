enum Environment {
  dev,
  prod,
}
abstract class AppEnvironment{
  static late String title;
  static late String baseUrl;
  static late bool kDebug;
  static late Environment _environment;
  static Environment get environment => _environment;
  static setupEnv(Environment env){
    _environment = env;
    switch(env){
      case Environment.dev:
        {
          title = '3M Reflective Verify Test';
          baseUrl = 'https://usermanagement-test.elorca.com/api';
          kDebug = true;
          break;
        }
      case Environment.prod:
        {
          title = '3M Reflective Verify';
          baseUrl = 'https://mmm.elentrika.com/api';
          kDebug = false;
          break;
        }
    }
  }
}
