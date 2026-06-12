# Part 3: Practical Coding Questions

These files contain simple answers for the practical coding part of the assignment.

## 1. API call and list display in Flutter

File: `flutter/api_list_example.dart`

This example calls `https://dummyjson.com/products` using Dio and shows products in a `ListView`.

## 2. Pagination in Flutter

File: `flutter/pagination_example.dart`

This example uses `limit` and `skip`.
When the user scrolls near the bottom, the next page is loaded.

## 3. Debounce function in Dart

File: `flutter/debounce_function.dart`

This example cancels the old timer and runs the search after a short delay.

Basic use:

```dart
final debouncer = SearchDebouncer();

debouncer.run(() {
  // call search function here
});
```

## 4. Reverse string in Java

File: `java/ReverseString.java`

This reverses a string using a loop and `charAt`.

Run:

```bash
javac ReverseString.java
java ReverseString
```

## 5. Duplicate elements in Java

File: `java/FindDuplicates.java`

This checks each number with the remaining array items and prints duplicates one time.

Run:

```bash
javac FindDuplicates.java
java FindDuplicates
```
