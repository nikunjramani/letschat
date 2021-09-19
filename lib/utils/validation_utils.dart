class ValidationUtils {
  static String validateMobile(String value) {
    String pattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
    RegExp regExp = new RegExp(pattern);
    if (value.length == 0) {
      return 'Please enter mobile number';
    } else if (!regExp.hasMatch(value)) {
      return 'Please enter valid mobile number';
    }
    return null;
  }

  static String validateNonEmpty(String value) {
// Indian Mobile number are of 10 digit only
    if (value.length == 0)
      return 'field is required!';
    else
      return null;
  }

  static String validateMinLength(String value, {int length = 3}) {
    if (value.length < length)
      return 'minimum $length character are required !';
    else
      return null;
  }

  static String validatePhone(String value) {
// Indian Mobile number are of 10 digit only
    if (value.length < 10)
      return 'valid phone number is required !';
    else
      return null;
  }

  static String validateEmail(String value) {
    if (!RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(value))
      return 'valid email is required !';
    else
      return null;
  }

  static String validateWebsite(String value) {
    bool _validURL = Uri.parse(value).isAbsolute;

    if (!_validURL)
      return 'valid url is required!';
    else
      return null;
  }
}
