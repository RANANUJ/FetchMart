public class ReverseString {
    public static void main(String[] args) {
        String text = "hello";
        String answer = reverseString(text);
        System.out.println(answer);
    }

    static String reverseString(String text) {
        String result = "";

        for (int i = text.length() - 1; i >= 0; i--) {
            result = result + text.charAt(i);
        }

        return result;
    }
}
