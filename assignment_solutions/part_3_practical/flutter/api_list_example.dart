import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ApiListExample extends StatefulWidget {
  const ApiListExample({super.key});

  @override
  State<ApiListExample> createState() => _ApiListExampleState();
}

class _ApiListExampleState extends State<ApiListExample> {
  List<Map<String, dynamic>> products = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    getProducts();
  }

  Future<void> getProducts() async {
    try {
      Dio dio = Dio();
      Response response = await dio.get('https://dummyjson.com/products');

      List items = response.data['products'];

      setState(() {
        products = items
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        errorMessage = 'Failed to load products';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: buildBody(),
    );
  }

  Widget buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage.isNotEmpty) {
      return Center(child: Text(errorMessage));
    }

    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        Map<String, dynamic> product = products[index];

        return ListTile(
          leading: Image.network(
            product['thumbnail'],
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          ),
          title: Text(product['title']),
          subtitle: Text('\$${product['price']}'),
        );
      },
    );
  }
}
