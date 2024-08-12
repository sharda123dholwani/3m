import 'env.dart';
bool printEnable = AppEnvironment.kDebug;/*define k debug variable in env.dart */
void printLine(var txt){
  if (printEnable) {
    print(txt);
  }
}
