// ignore_for_file: avoid_print

void main() {
  List<int> numbers = [2, 7, 11, 15];
  int target = 9;

  List<int> answer = twoSum(numbers, target);
  print(answer);
}

List<int> twoSum(List<int> numbers, int target) {
  Map<int, int> seenNumbers = {};

  for (int i = 0; i < numbers.length; i++) {
    int currentNumber = numbers[i];
    int neededNumber = target - currentNumber;

    if (seenNumbers.containsKey(neededNumber)) {
      return [seenNumbers[neededNumber]!, i];
    }

    seenNumbers[currentNumber] = i;
  }

  return [];
}
