# ht_crud_client

![coverage: percentage](https://img.shields.io/badge/coverage-100-green)
[![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)
[![License: PolyForm Free Trial](https://img.shields.io/badge/License-PolyForm%20Free%20Trial-blue)](https://polyformproject.org/licenses/free-trial/1.0.0)

## Description

This package defines a generic, abstract interface (`HtCrudClient<T>`) for performing standard CRUD (Create, Read, Update, Delete) operations on a resource of type `T`. It establishes a contract for data clients, expecting implementations to handle underlying communication (like HTTP) and serialization/deserialization.

This package is designed to be implemented by concrete client classes that interact with specific data sources or APIs.

## Getting Started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  ht_crud_client: ^latest # Replace with the actual version constraint
```

Then, import the package:

```dart
import 'package:ht_crud_client/ht_crud_client.dart';
```

## Features

*   **Generic CRUD Interface:** Defines standard methods for:
    *   `create(T item)`: Create a new resource.
    *   `read(String id)`: Read a single resource by ID.
    *   `readAll()`: Read all resources.
    *   `update(String id, T item)`: Update an existing resource.
    *   `delete(String id)`: Delete a resource by ID.
*   **Type Safety:** Uses generics (`<T>`) to work with any data model.
*   **Serialization Agnostic:** Defines `FromJson<T>` and `ToJson<T>` typedefs, allowing implementations to use their preferred serialization logic.
*   **Standardized Error Handling:** Specifies expected `HtHttpException` subtypes (from `package:ht_http_client`) that implementations should throw on failure.

## Usage

Since `HtCrudClient<T>` is an abstract class, you need to create a concrete implementation for your specific resource type and data source (e.g., an HTTP API).

**Conceptual Implementation Example:**

```dart
import 'package:ht_crud_client/ht_crud_client.dart';
import 'package:ht_http_client/ht_http_client.dart'; // For HtHttpClient and exceptions

// Define your data model
class MyDataModel {
  final String id;
  final String name;

  MyDataModel({required this.id, required this.name});

  // Factory constructor for deserialization
  factory MyDataModel.fromJson(Map<String, dynamic> json) {
    return MyDataModel(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }

  // Method for serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

// Concrete implementation using HtHttpClient
class MyDataApiClient implements HtCrudClient<MyDataModel> {
  MyDataApiClient({required HtHttpClient httpClient})
      : _httpClient = httpClient;

  final HtHttpClient _httpClient;
  final String _endpoint = '/mydata'; // Base API endpoint for the resource

  // Provide the FromJson function for MyDataModel
  static MyDataModel _fromJson(Map<String, dynamic> json) =>
      MyDataModel.fromJson(json);

  // Provide the ToJson function for MyDataModel
  static Map<String, dynamic> _toJson(MyDataModel item) => item.toJson();

  @override
  Future<MyDataModel> create(MyDataModel item) async {
    final response = await _httpClient.post(
      _endpoint,
      body: _toJson(item),
    );
    // Assuming the API returns the created item in the body
    return _httpClient.parseResponse(response, _fromJson);
  }

  @override
  Future<MyDataModel> read(String id) async {
    final response = await _httpClient.get('$_endpoint/$id');
    return _httpClient.parseResponse(response, _fromJson);
  }

  @override
  Future<List<MyDataModel>> readAll() async {
    final response = await _httpClient.get(_endpoint);
    // Assuming the API returns a list of items
    return _httpClient.parseResponseAsList(response, _fromJson);
  }

  @override
  Future<MyDataModel> update(String id, MyDataModel item) async {
    final response = await _httpClient.put(
      '$_endpoint/$id',
      body: _toJson(item),
    );
    // Assuming the API returns the updated item
    return _httpClient.parseResponse(response, _fromJson);
  }

  @override
  Future<void> delete(String id) async {
    await _httpClient.delete('$_endpoint/$id');
    // No return value needed, exceptions handled by HtHttpClient
  }
}

// --- Usage in your application/repository ---
// final myApiClient = MyDataApiClient(httpClient: yourHtHttpClientInstance);
// final newItem = await myApiClient.create(MyDataModel(id: '', name: 'New Item'));
// final item = await myApiClient.read('some-id');
// final allItems = await myApiClient.readAll();
```

## License

This package is licensed under the [PolyForm Free Trial](LICENSE). Please review the terms before use.
