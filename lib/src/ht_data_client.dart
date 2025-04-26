import 'package:ht_http_client/ht_http_client.dart'
    hide HtHttpClient, TokenProvider;

/// A function that converts a JSON map to an object of type [T].
typedef FromJson<T> = T Function(Map<String, dynamic> json);

/// A function that converts an object of type [T] to a JSON map.
typedef ToJson<T> = Map<String, dynamic> Function(T item);

/// {@template ht_data_client}
/// Defines a generic interface for clients interacting with data resources of type [T].
/// While primarily focused on standard CRUD (Create, Read, Update, Delete) operations,
/// this interface can be extended to include other data access methods.
///
/// Implementations of this interface are expected to handle the underlying
/// communication (e.g., HTTP requests) and manage serialization/deserialization
/// via provided [FromJson] and [ToJson] functions if necessary.
/// {@endtemplate}
abstract class HtDataClient<T> {
  /// Creates a new resource item of type [T].
  ///
  /// Implementations should handle sending the [item] data to the appropriate
  /// endpoint (typically via POST).
  /// Returns the created item, potentially populated with server-assigned data
  /// (like an ID).
  ///
  /// Throws [HtHttpException] or its subtypes on failure:
  /// - [BadRequestException] for validation errors or malformed requests.
  /// - [UnauthorizedException] if authentication is required and missing/invalid.
  /// - [ForbiddenException] if the authenticated user lacks permission.
  /// - [ServerException] for general server-side errors (5xx).
  /// - [NetworkException] for connectivity issues.
  /// - [UnknownException] for other unexpected errors during the HTTP call.
  /// Can also throw other exceptions during serialization.
  Future<T> create(T item);

  /// Reads a single resource item of type [T] by its unique [id].
  ///
  /// Implementations should handle retrieving the data for the given [id]
  /// (typically via GET `endpoint/{id}`).
  /// Returns the deserialized item.
  ///
  /// Throws [HtHttpException] or its subtypes on failure:
  /// - [NotFoundException] if no item exists with the given [id].
  /// - [UnauthorizedException] if authentication is required and missing/invalid.
  /// - [ForbiddenException] if the authenticated user lacks permission.
  /// - [ServerException] for general server-side errors (5xx).
  /// - [NetworkException] for connectivity issues.
  /// - [UnknownException] for other unexpected errors during the HTTP call.
  /// Can also throw other exceptions during deserialization.
  Future<T> read(String id);

  /// Reads all resource items of type [T].
  ///
  /// Implementations should handle retrieving the complete collection of items
  /// (typically via GET `endpoint`).
  /// Returns a list of deserialized items.
  ///
  /// Supports pagination using the [startAfterId] and [limit] parameters.
  ///
  /// Throws [HtHttpException] or its subtypes on failure:
  /// - [UnauthorizedException] if authentication is required and missing/invalid.
  /// - [ForbiddenException] if the authenticated user lacks permission.
  /// - [ServerException] for general server-side errors (5xx).
  /// - [NetworkException] for connectivity issues.
  /// - [UnknownException] for other unexpected errors during the HTTP call.
  /// Can also throw [FormatException] if the received data (e.g., list items)
  /// is malformed during deserialization.
  Future<List<T>> readAll({String? startAfterId, int? limit});

  /// Reads multiple resource items of type [T] based on a [query].
  ///
  /// Implementations should handle retrieving data based on the provided
  /// [query] parameters (typically via GET `endpoint` with query parameters).
  /// Returns a list of deserialized items matching the query.
  ///
  /// Supports pagination using the [startAfterId] and [limit] parameters.
  ///
  /// Example query map:
  /// ```dart
  /// {
  ///   'authorId': 'some-author-id',
  ///   'category': 'technology',
  ///   'sortBy': 'publishDate',
  ///   'sortOrder': 'desc',
  ///   'status': 'published',
  /// }
  /// ```
  ///
  /// Throws [HtHttpException] or its subtypes on failure:
  /// - [BadRequestException] for invalid query parameters.
  /// - [UnauthorizedException] if authentication is required and missing/invalid.
  /// - [ForbiddenException] if the authenticated user lacks permission.
  /// - [ServerException] for general server-side errors (5xx).
  /// - [NetworkException] for connectivity issues.
  /// - [UnknownException] for other unexpected errors during the HTTP call.
  /// Can also throw [FormatException] if the received data (e.g., list items)
  /// is malformed during deserialization.
  Future<List<T>> readAllByQuery(
    Map<String, dynamic> query, {
    String? startAfterId,
    int? limit,
  });

  /// Updates an existing resource item of type [T] identified by [id].
  ///
  /// Implementations should handle sending the updated [item] data for the
  /// specified [id] (typically via PUT `endpoint/{id}`).
  /// Returns the updated item as confirmed by the source.
  ///
  /// Throws [HtHttpException] or its subtypes on failure:
  /// - [BadRequestException] for validation errors or malformed requests.
  /// - [NotFoundException] if no item exists with the given [id].
  /// - [UnauthorizedException] if authentication is required and missing/invalid.
  /// - [ForbiddenException] if the authenticated user lacks permission.
  /// - [ServerException] for general server-side errors (5xx).
  /// - [NetworkException] for connectivity issues.
  /// - [UnknownException] for other unexpected errors during the HTTP call.
  /// Can also throw other exceptions during serialization/deserialization.
  Future<T> update(String id, T item);

  /// Deletes a resource item identified by [id].
  ///
  /// Implementations should handle the request to remove the item with the
  /// given [id] (typically via DELETE `endpoint/{id}`).
  /// Returns `void` upon successful deletion.
  ///
  /// Throws [HtHttpException] or its subtypes on failure:
  /// - [NotFoundException] if no item exists with the given [id].
  /// - [UnauthorizedException] if authentication is required and missing/invalid.
  /// - [ForbiddenException] if the authenticated user lacks permission.
  /// - [ServerException] for general server-side errors (5xx).
  /// - [NetworkException] for connectivity issues.
  /// - [UnknownException] for other unexpected errors during the HTTP call.
  Future<void> delete(String id);
}
