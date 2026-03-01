
class StringValidation {

  static String? validatePass(String value, String? msg1, String? msg2,
      {required bool onlyRequired}) {
    if (onlyRequired) {
      if (value.isEmpty) {
        return msg1;
      } else {
        return null;
      }
    } else {
      if (value.isEmpty) {
        return msg1;
      } else if (!RegExp(
          r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!%@#\$&*~_.?=^`-]).{8,}$')
          .hasMatch(value)) {
        return msg2;
      } else {
        return null;
      }
    }
  }
  static String? validateEmail(String value) {
    // Simple email regex pattern
    bool isValidEmail = RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    ).hasMatch(value);

    if (!isValidEmail) {
      return 'Please enter a valid email address';
    }
    return null; // Valid email returns null (no error)
  }
  static String? validateField(String value, String? msg) {
    if (value.isEmpty) {
      return msg;
    } else {
      return null;
    }
  }



  static String capitalize(String s) => s[0].toUpperCase() + s.substring(1);
}
