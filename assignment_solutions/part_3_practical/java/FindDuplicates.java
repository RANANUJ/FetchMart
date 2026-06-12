public class FindDuplicates {
    public static void main(String[] args) {
        int[] numbers = {1, 2, 3, 2, 4, 1, 5};
        findDuplicates(numbers);
    }

    static void findDuplicates(int[] numbers) {
        for (int i = 0; i < numbers.length; i++) {
            boolean alreadyPrinted = false;

            for (int k = 0; k < i; k++) {
                if (numbers[k] == numbers[i]) {
                    alreadyPrinted = true;
                    break;
                }
            }

            if (alreadyPrinted) {
                continue;
            }

            for (int j = i + 1; j < numbers.length; j++) {
                if (numbers[i] == numbers[j]) {
                    System.out.println(numbers[i]);
                    break;
                }
            }
        }
    }
}
