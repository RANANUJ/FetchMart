# Part 2: DSA Questions

## Q1: Two Sum Variant

File: `two_sum_variant.dart`

The solution uses a map to store numbers already visited with their index.
For every number, it checks if the needed value is already present.

Time complexity: `O(n)`

Run:

```bash
dart run assignment_solutions/part_2_dsa/two_sum_variant.dart
```

## Q2: Longest Substring Without Repeating Characters

File: `longest_substring.dart`

The solution uses the sliding window approach.
It stores the last index of each character and moves the start position when a repeated character is found.
Input:

```text
abcabcbb
```

Output:

```text
3
```

Time complexity: `O(n)`

Run:

```bash
dart run assignment_solutions/part_2_dsa/longest_substring.dart
```
