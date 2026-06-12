import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class PaginationExample extends StatefulWidget {
  const PaginationExample({super.key});

  @override
  State<PaginationExample> createState() => _PaginationExampleState();
}

class _PaginationExampleState extends State<PaginationExample> {
  final ScrollController scrollController = ScrollController();

  List<Map<String, dynamic>> products = [];
  bool isLoading = false;
  bool hasMoreData = true;
  int limit = 10;
  int skip = 0;

  @override
  void initState() {
    super.initState();
    getProducts();

    scrollController.addListener(() {
      if (scrollController.position.extentAfter < 200) {
        getProducts();
      }
    });
  }

  Future<void> getProducts() async {
    if (isLoading || !hasMoreData) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      Dio dio = Dio();
      Response response = await dio.get(
        'https://dummyjson.com/products',
        queryParameters: {'limit': limit, 'skip': skip},
      );

      List items = response.data['products'];
      List<Map<String, dynamic>> newProducts = items
          .map((item) => Map<String, dynamic>.from(item))
          .toList();

      setState(() {
        products.addAll(newProducts);
        skip = skip + limit;
        hasMoreData = newProducts.length == limit;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pagination')),
      body: ListView.builder(
        controller: scrollController,
        itemCount: products.length + 1,
        itemBuilder: (context, index) {
          if (index == products.length) {
            if (hasMoreData) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: Text('No more products')),
            );
          }

          Map<String, dynamic> product = products[index];

          return ListTile(
            title: Text(product['title']),
            subtitle: Text('\$${product['price']}'),
          );
        },
      ),
    );
  }
}
