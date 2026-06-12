// ignore_for_file: avoid_print

void main() {
  String input = 'abcabcbb';

  int answer = longestSubstringWithoutRepeating(input);
  print(answer);
}

int longestSubstringWithoutRepeating(String text) {
  Map<String, int> lastIndex = {};
  int start = 0;
  int maxLength = 0;

  for (int i = 0; i < text.length; i++) {
    String currentChar = text[i];

    if (lastIndex.containsKey(currentChar) &&
        lastIndex[currentChar]! >= start) {
      start = lastIndex[currentChar]! + 1;
    }

    lastIndex[currentChar] = i;

    int currentLength = i - start + 1;
    if (currentLength > maxLength) {
      maxLength = currentLength;
    }
  }

  return maxLength;
}
