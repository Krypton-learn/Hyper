void main() {
  final validUsernames = ['user_name', 'username123', 'UserName', '123456'];
  final invalidUsernames = [
    'user name', // Space
    'user@name', // Special char
    'user-name', // Dash (only underscore allowed)
    'user.name', // Dot
    ' user',     // Leading space
    'user ',     // Trailing space
  ];

  final regex = RegExp(r'^[a-zA-Z0-9_]+$');

  print('--- Testing Valid Usernames ---');
  for (var name in validUsernames) {
    if (regex.hasMatch(name)) {
      print('PASS: "$name" is valid');
    } else {
      print('FAIL: "$name" should be valid');
    }
  }

  print('\n--- Testing Invalid Usernames ---');
  for (var name in invalidUsernames) {
    if (!regex.hasMatch(name)) {
      print('PASS: "$name" is invalid');
    } else {
      print('FAIL: "$name" should be invalid');
    }
  }
}
