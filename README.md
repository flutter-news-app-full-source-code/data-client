# ht_data_client

![coverage: percentage](https://img.shields.io/badge/coverage-100-green)
[![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)
[![License: PolyForm Free Trial](https://img.shields.io/badge/License-PolyForm%20Free%20Trial-blue)](https://polyformproject.org/licenses/free-trial/1.0.0)

## Description

This package defines a generic, abstract interface (`HtDataClient<T>`) for
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
  ht_data_client:
    git:
      url: https://github.com/headlines-toolkit/ht-data-client.git
```

Then, import the package:

```dart
import 'package:ht_data_client/ht_data_client.dart';
```

## Features

*   **Generic Data Client Interface:** Defines standard methods for common data
    access patterns. Methods include an optional `userId` parameter to
    distinguish between user-scoped and global resource operations:
    *   `create({String? userId, required T item})`: Create a new resource.
        If `userId` is null, may represent a global creation.
    *   `read({String? userId, required String id})`: Read a single resource
         by ID. If `userId` is null, reads a global resource.
    *   `readAll({String? userId, String? startAfterId, int? limit, String? sortBy, SortOrder? sortOrder})`: Read
        all resources. If `userId` is null, reads all global resources.
    *   `readAllByQuery(Map<String, dynamic> query, {String? userId, String? startAfterId, int? limit, String? sortBy, SortOrder? sortOrder})`:
        Read multiple resources based on a query. If `userId` is null, queries
        global resources.
    *   `update({String? userId, required String id, required T item})`:
        Update an existing resource by ID. If `userId` is null, updates a
        global resource.
    *   `delete({String? userId, required String id})`: Delete a resource by
        ID. If `userId` is null, deletes a global resource.
*   **Support for User-Scoped and Global Data:** The optional `userId`
    parameter allows a single client implementation to handle data specific
    to a user or data that is globally accessible.
*   **Pagination and Sorting Support:** Includes parameters for `startAfterId`, `limit`, `sortBy`, and `sortOrder`
    in methods returning multiple items.
*   **Querying Capability:** Provides a method to fetch data based on
    structured query parameters.
*   **Type Safety:** Uses generics (`<T>`) to work with any data model.
*   **Serialization Agnostic:** Defines `FromJson<T>` and `ToJson<T>` typedefs,
    allowing implementations to use their preferred serialization logic.
*   **Standardized Error Handling:** Specifies expected `HtHttpException`
    subtypes (from `package:ht_shared`) that implementations should throw on
    failure.

## Usage

Since `HtDataClient<T>` is an abstract class, you need to create a concrete
implementation for your specific resource type and data source (e.g., an HTTP
API). This implementation will provide the logic for the CRUD, querying, and
pagination methods defined by the interface, handling the optional `userId`.

**Conceptual Implementation Example:**

```dart
import 'package:ht_data_client/ht_data_client.dart';
import 'package:ht_shared/ht_shared.dart'; // For HtHttpException and models

// Define your data model (assuming it's in ht_shared or similar)
// class MyDataModel { ... }

// Concrete implementation using HtHttpClient (assuming it exists)
// import 'package:ht_http_client/ht_http_client.dart';

// class MyDataApiClient implements HtDataClient<MyDataModel> {
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
//     String? startAfterId,
//     int? limit,
//     String? sortBy,
//     SortOrder? sortOrder,
//   }) async {
//     final path = _buildPath(userId);
//     final queryParameters = <String, dynamic>{
//       if (startAfterId != null) 'startAfterId': startAfterId,
//       if (limit != null) 'limit': limit,
//       if (sortBy != null) 'sortBy': sortBy,
//       if (sortOrder != null) 'sortOrder': sortOrder.name,
//     };
//     final response = await _httpClient.get<Map<String, dynamic>>(
//       path,
//       queryParameters: queryParameters,
//     );
//     return SuccessApiResponse.fromJson(
//       response,
//       (json) => PaginatedResponse.fromJson(json as Map<String, dynamic>, _fromJson),
//     );
//   }

//   @override
//   Future<SuccessApiResponse<PaginatedResponse<MyDataModel>>> readAllByQuery(
//     Map<String, dynamic> query, {
//     String? userId,
//     String? startAfterId,
//     int? limit,
//     String? sortBy,
//     SortOrder? sortOrder,
//   }) async {
//     final path = _buildPath(userId);
//     final queryParameters = <String, dynamic>{
//       ...query,
//       if (startAfterId != null) 'startAfterId': startAfterId,
//       if (limit != null) 'limit': limit,
//       if (sortBy != null) 'sortBy': sortBy,
//       if (sortOrder != null) 'sortOrder': sortOrder.name,
//     };
//     final response = await _httpClient.get<Map<String, dynamic>>(
//       path,
//       queryParameters: queryParameters,
//     );
//     return SuccessApiResponse.fromJson(
//       response,
//       (json) => PaginatedResponse.fromJson(json as Map<String, dynamic>, _fromJson),
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
// }

// --- Usage in your application/repository ---
// Assuming you have an instance of MyDataApiClient:
// final myApiClient = MyDataApiClient(httpClient: yourHtHttpClientInstance);

// // Example: Accessing user-scoped data
// final userId = 'user123'; // Replace with actual user ID
// final userItem = await myApiClient.read(userId: userId, id: 'some-user-item-id');
// final userItems = await myApiClient.readAll(userId: userId);

// // Example: Accessing global data (e.g., Headlines)
// // Assuming T is Headline for this client instance
// final globalHeadlines = await myApiClient.readAll(userId: null);
// final queriedHeadlines = await myApiClient.readAllByQuery(
//   {'category': 'technology'},
//   userId: null,
// );
```

## License

This package is licensed under the [PolyForm Free Trial](LICENSE). Please
review the terms before use.
