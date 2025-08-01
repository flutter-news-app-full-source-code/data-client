# data_client

![coverage: percentage](https://img.shields.io/badge/coverage-xx-green)
[![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)
[![License: PolyForm Free Trial](https://img.shields.io/badge/License-PolyForm%20Free%20Trial-blue)](https://polyformproject.org/licenses/free-trial/1.0.0)

## Description

This package defines a generic, abstract interface (`DataClient<T>`) for
interacting with data resources of type `T`. It is designed to handle
operations for *both* user-scoped resources (where data is specific to a user)
and global resources (where data is not tied to a specific user, e.g.,
admin-managed content). The optional `userId` parameter in methods is used to
differentiate between these two use cases.

While its core focus is on providing a standardized contract for common data
access patterns, including standard CRUD (Create, Read, Update, Delete)
operations, the interface is designed to be extensible to support additional
resource-specific methods. It establishes a contract for data clients,
expecting implementations to handle underlying communication (like HTTP) and
manage serialization/deserialization.

This package is designed to be implemented by concrete client classes that
interact with specific data sources or APIs.

## Getting Started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  data_client:
    git:
      url: https://github.com/flutter-news-app-full-source-code/data-client.git
```

Then, import the package:

```dart
import 'package:data_client/data_client.dart';
```

## Features

*   **Generic Data Client Interface:** Defines standard methods for common data
    access patterns. Methods include an optional `userId` parameter to
    distinguish between user-scoped and global resource operations:
    *   `create({String? userId, required T item})`: Create a new resource.
        If `userId` is null, may represent a global creation.
    *   `read({String? userId, required String id})`: Read a single resource
        by ID. If `userId` is null, reads a global resource.
    *   `readAll({String? userId, Map<String, dynamic>? filter, PaginationOptions? pagination, List<SortOption>? sort})`:
        Reads multiple resources with powerful filtering, sorting, and pagination.
    *   `update({String? userId, required String id, required T item})`:
        Update an existing resource by ID. If `userId` is null, updates a
        global resource.
    *   `delete({String? userId, required String id})`: Delete a resource by
        ID. If `userId` is null, deletes a global resource.
*   `count({String? userId, Map<String, dynamic>? filter})`: Efficiently
    counts resources matching a filter without fetching them.
*   `aggregate({String? userId, required List<Map<String, dynamic>> pipeline})`:
    Executes a complex, server-side aggregation pipeline for analytics and
    reporting.
*   **Support for User-Scoped and Global Data:** The optional `userId`
    parameter allows a single client implementation to handle data specific
    to a user or data that is globally accessible.
*   **Advanced Pagination and Sorting:** Supports robust, cursor-based pagination
    (via `PaginationOptions`) and multi-field sorting (`List<SortOption>`),
    ideal for document databases.
*   **Rich Querying Capability:** The `readAll` method accepts a `filter` map
    that can be used to construct complex, MongoDB-style queries.
*   **Type Safety:** Uses generics (`<T>`) to work with any data model.
*   **Serialization Agnostic:** Defines `FromJson<T>` and `ToJson<T>` typedefs,
    allowing implementations to use their preferred serialization logic.
*   **Standardized Error Handling:** Specifies expected `HttpException`
    subtypes (from `package:core`) that implementations should throw on
    failure.

## Usage

Since `DataClient<T>` is an abstract class, you need to create a concrete
implementation for your specific resource type and data source (e.g., an HTTP
API). This implementation will provide the logic for the CRUD, querying, and
pagination methods defined by the interface, handling the optional `userId`.

**Conceptual Implementation Example:**

```dart
import 'dart:convert'; // For jsonEncode
import 'package:data_client/data_client.dart';
import 'package:core/core.dart'; // For HttpException and models

// Define your data model (assuming it's in core or similar)
// class MyDataModel { ... }

// Concrete implementation using HtHttpClient (assuming it exists)
// import 'package:ht_http_client/ht_http_client.dart';

// class MyDataApiClient implements DataClient<MyDataModel> {
//   MyDataApiClient({required HtHttpClient httpClient})
//       : _httpClient = httpClient;

//   final HtHttpClient _httpClient;
//   final String _endpoint = '/mydata'; // Base API endpoint for the resource

//   // Provide the FromJson function for MyDataModel
//   static MyDataModel _fromJson(Object? json) =>
//       MyDataModel.fromJson(json as Map<String, dynamic>);

//   // Provide the ToJson function for MyDataModel
//   static Map<String, dynamic> _toJson(MyDataModel item) => item.toJson();

//   // Helper to build path, potentially including userId
//   String _buildPath(String? userId, {String? id}) {
//     if (userId != null) {
//       return '/users/$userId$_endpoint${id != null ? '/$id' : ''}';
//     }
//     // Handle global endpoint if userId is null
//     return '$_endpoint${id != null ? '/$id' : ''}';
//   }

//   @override
//   Future<SuccessApiResponse<MyDataModel>> create({
//     String? userId,
//     required MyDataModel item,
//   }) async {
//     final path = _buildPath(userId);
//     final response = await _httpClient.post<Map<String, dynamic>>(
//       path,
//       data: _toJson(item),
//     );
//     return SuccessApiResponse.fromJson(response, _fromJson);
//   }

//   @override
//   Future<SuccessApiResponse<MyDataModel>> read({
//     String? userId,
//     required String id,
//   }) async {
//     final path = _buildPath(userId, id: id);
//     final response = await _httpClient.get<Map<String, dynamic>>(path);
//     return SuccessApiResponse.fromJson(response, _fromJson);
//   }

//   @override
//   Future<SuccessApiResponse<PaginatedResponse<MyDataModel>>> readAll({
//     String? userId,
//     Map<String, dynamic>? filter,
//     PaginationOptions? pagination,
//     List<SortOption>? sort,
//   }) async {
//     final path = _buildPath(userId);
//     final queryParameters = <String, dynamic>{
//       // The backend API would need to know how to interpret these.
//       // 'filter' might be JSON-encoded, and 'sort' could be a string.
//       if (filter != null) 'filter': jsonEncode(filter),
//       if (pagination?.cursor != null) 'cursor': pagination!.cursor,
//       if (pagination?.limit != null) 'limit': pagination!.limit,
//       if (sort != null)
//         'sort': sort.map((s) => '${s.field}:${s.order.name}').join(','),
//     };
//     final response = await _httpClient.get<Map<String, dynamic>>(
//       path,
//       queryParameters: queryParameters,
//     );
//     return SuccessApiResponse.fromJson(
//       response, (json) => PaginatedResponse.fromJson(
//         json as Map<String, dynamic>,
//         _fromJson,
//       ),
//     );
//   }

//   @override
//   Future<SuccessApiResponse<MyDataModel>> update({
//     String? userId,
//     required String id,
//     required MyDataModel item,
//   }) async {
//     final path = _buildPath(userId, id: id);
//     final response = await _httpClient.put<Map<String, dynamic>>(
//       path,
//       data: _toJson(item),
//     );
//     return SuccessApiResponse.fromJson(response, _fromJson);
//   }

//   @override
//   Future<void> delete({String? userId, required String id}) async {
//     final path = _buildPath(userId, id: id);
//     await _httpClient.delete<void>(path);
//   }

//   @override
//   Future<SuccessApiResponse<int>> count({
//     String? userId,
//     Map<String, dynamic>? filter,
//   }) async {
//     // This conceptual path assumes a dedicated endpoint for counting.
//     final path = _buildPath(userId, pathSuffix: '/count');
//     final queryParameters = <String, dynamic>{
//       if (filter != null) 'filter': jsonEncode(filter),
// }
//     final response = await _httpClient.get<Map<String, dynamic>>(
//       path,
//       queryParameters: queryParameters,
//     );
//     // Assuming the API returns a SuccessApiResponse with an int data field.
//     return SuccessApiResponse.fromJson(response, (json) => json as int);
//   }

//   @override
//   Future<SuccessApiResponse<List<Map<String, dynamic>>>> aggregate({
//     String? userId,
//     required List<Map<String, dynamic>> pipeline,
//   }) async {
//     // This conceptual path assumes a dedicated endpoint for aggregation.
//     final path = _buildPath(userId, pathSuffix: '/aggregate');
//     final response = await _httpClient.post<Map<String, dynamic>>(
//       path,
//       data: {'pipeline': pipeline},
//     );
//     // Assuming the API returns a SuccessApiResponse with a list of maps.
//     return SuccessApiResponse.fromJson(
//       response,
//       (json) => List<Map<String, dynamic>>.from(json as List),
//     );
//   }
// }

// --- Usage in your application/repository ---
// Assuming you have an instance of MyDataApiClient:
// final myApiClient = MyDataApiClient(httpClient: yourHtHttpClientInstance);

// // Example: Accessing user-scoped data
// final userId = 'user123'; // Replace with actual user ID
// final userItem = await myApiClient.read(userId: userId, id: 'some-user-item-id');
// final allUserItems = await myApiClient.readAll(userId: userId);

// // Example: Accessing global data with filtering and sorting
// final queriedItems = await myApiClient.readAll(
//   userId: null, // Global query
//   filter: {'category': 'technology', 'status': 'published'},
//   sort: [
//     SortOption('publishDate', SortOrder.desc),
//   ],
//   pagination: PaginationOptions(limit: 10),
// );

// // Example: Counting items
// final countResponse = await myApiClient.count(
//   userId: null,
//   filter: {'status': 'published'},
// );
// print('Published items: ${countResponse.data}');

// // Example: Running an aggregation pipeline
// final topTopicsResponse = await myApiClient.aggregate(
//   pipeline: [
//     { '\$group': { '_id': '\$topic.id', 'count': { '\$sum': 1 } } },
//     { '\$sort': { 'count': -1 } },
//     { '\$limit': 3 }
//   ],
// );
// print('Top topics: ${topTopicsResponse.data}');
```

## 🔑 Licensing

This package is source-available and licensed under the [PolyForm Free Trial 1.0.0](LICENSE). Please review the terms before use.

For commercial licensing options that grant the right to build and distribute unlimited applications, please visit the main [**Flutter News App - Full Source Code Toolkit**](https://github.com/flutter-news-app-full-source-code) organization.
