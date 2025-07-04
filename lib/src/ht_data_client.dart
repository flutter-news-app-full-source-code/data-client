import 'package:ht_shared/ht_shared.dart';

/// A function that converts a JSON map to an object of type [T].
typedef FromJson<T> = T Function(Map<String, dynamic> json);

/// A function that converts an object of type [T> to a JSON map.
typedef ToJson<T> = Map<String, dynamic> Function(T item);

/// {@template ht_data_client}
/// Defines a generic interface for clients interacting with data resources
/// of type [T].
///
/// This interface is designed to handle operations for *both* user-scoped
/// resources (where data is specific to a user) and global resources
/// (where data is not tied to a specific user, e.g., admin-managed content).
/// The optional "userId" parameter in methods is used to differentiate
/// between these two use cases.
///
/// While primarily focused on standard CRUD (Create, Read, Update, Delete)
/// operations, this interface can be extended to include other data access
/// methods.
///
/// Implementations of this interface are expected to handle the underlying
/// communication (e.g., HTTP requests) and manage serialization/deserialization
/// via provided [FromJson] and [ToJson] functions if necessary.
/// Implementations must check the "userId" parameter: if provided, scope
/// the operation to that user; if `null`, perform the operation on global
/// resources (where applicable for the specific method).
/// {@endtemplate}
abstract class HtDataClient<T> {
  /// Creates a new resource item of type [T].
  ///
  /// - [userId]: The unique identifier of the user performing the operation.
  ///   If `null`, the operation may be considered a global creation (e.g.,
  ///   by an admin), depending on the resource type [T]. Implementations
  ///   must handle the `null` case appropriately.
  /// - [item]: The resource item to create.
  ///
  /// Implementations should handle sending the [item] data to the appropriate
  /// endpoint (typically via POST), potentially scoped by the provided [userId].
  /// Returns a [SuccessApiResponse] containing the created item, potentially
  /// populated with server-assigned data (like an ID).
  ///
  /// Throws [HtHttpException] or its subtypes on failure:
  /// - [BadRequestException] for validation errors or malformed requests.
  /// - [UnauthorizedException] if authentication is required and missing/invalid.
  /// - [ForbiddenException] if the authenticated user lacks permission.
  /// - [ServerException] for general server-side errors (5xx).
  /// - [NetworkException] for connectivity issues.
  /// - [UnknownException] for other unexpected errors during the HTTP call.
  /// Can also throw other exceptions during serialization.
  Future<SuccessApiResponse<T>> create({required T item, String? userId});

  /// Reads a single resource item of type [T] by its unique [id].
  ///
  /// - [userId]: The unique identifier of the user performing the operation.
  ///   If `null`, the operation may be considered a global read, depending
  ///   on the resource type [T]. Implementations must handle the `null` case.
  /// - [id]: The unique identifier of the resource item to read.
  ///
  /// Implementations should handle retrieving the data for the given [id]
  /// (typically via GET `endpoint/{id}`), potentially scoped by the provided [userId].
  /// Returns a [SuccessApiResponse] containing the deserialized item.
  ///
  /// Throws [HtHttpException] or its subtypes on failure:
  /// - [NotFoundException] if no item exists with the given [id] (scoped by user
  ///   if [userId] is provided, or globally if [userId] is `null`).
  /// - [UnauthorizedException] if authentication is required and missing/invalid.
  /// - [ForbiddenException] if the authenticated user lacks permission.
  /// - [ServerException] for general server-side errors (5xx).
  /// - [NetworkException] for connectivity issues.
  /// - [UnknownException] for other unexpected errors during the HTTP call.
  /// Can also throw other exceptions during deserialization.
  Future<SuccessApiResponse<T>> read({required String id, String? userId});

  /// Reads all resource items of type [T].
  ///
  /// - [userId]: The unique identifier of the user performing the operation.
  ///   If `null`, the operation should retrieve all *global* resources of type [T].
  ///   If provided, the operation should retrieve all resources scoped to that user.
  ///   Implementations must handle the `null` case.
  /// - [startAfterId]: Optional ID to start pagination after.
  /// - [limit]: Optional maximum number of items to return.
  /// - [sortBy]: Optional field name to sort the results by.
  /// - [sortOrder]: Optional direction for sorting (`asc` or `desc`).
  ///
  /// Implementations should handle retrieving the complete collection of items
  /// (typically via GET `endpoint`), scoped by the provided [userId] or globally.
  /// Returns a [SuccessApiResponse] containing a [PaginatedResponse] with the
  /// list of deserialized items.
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
  Future<SuccessApiResponse<PaginatedResponse<T>>> readAll({
    String? userId,
    String? startAfterId,
    int? limit,
    String? sortBy,
    SortOrder? sortOrder,
  });

  /// Reads multiple resource items of type [T] based on a [query].
  ///
  /// - [userId]: The unique identifier of the user performing the operation.
  ///   If `null`, the operation should retrieve *global* resources matching the
  ///   query. If provided, the operation should retrieve resources scoped to
  ///   that user matching the query. Implementations must handle the `null` case.
  /// - [query]: Map of query parameters to filter results.
  /// - [startAfterId]: Optional ID to start pagination after.
  /// - [limit]: Optional maximum number of items to return.
  /// - [sortBy]: Optional field name to sort the results by.
  /// - [sortOrder]: Optional direction for sorting (`asc` or `desc`).
  ///
  /// Implementations should handle retrieving data based on the provided
  /// [query] parameters (typically via GET `endpoint` with query parameters),
  /// potentially scoped by the provided [userId] or globally.
  /// Returns a [SuccessApiResponse] containing a [PaginatedResponse] with the
  /// list of deserialized items matching the query.
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
  Future<SuccessApiResponse<PaginatedResponse<T>>> readAllByQuery(
    Map<String, dynamic> query, {
    String? userId,
    String? startAfterId,
    int? limit,
    String? sortBy,
    SortOrder? sortOrder,
  });

  /// Updates an existing resource item of type [T] identified by [id].
  ///
  /// - [userId]: The unique identifier of the user performing the operation.
  ///   If `null`, the operation may be considered a global update (e.g.,
  ///   by an admin), depending on the resource type [T]. Implementations
  ///   must handle the `null` case appropriately.
  /// - [id]: The unique identifier of the resource item to update.
  /// - [item]: The updated resource item data.
  ///
  /// Implementations should handle sending the updated [item] data for the
  /// specified [id] (typically via PUT `endpoint/{id}`), potentially scoped
  /// by the provided [userId].
  /// Returns a [SuccessApiResponse] containing the updated item as confirmed
  /// by the source.
  ///
  /// Throws [HtHttpException] or its subtypes on failure:
  /// - [BadRequestException] for validation errors or malformed requests.
  /// - [NotFoundException] if no item exists with the given [id] (scoped by user
  ///   if [userId] is provided, or globally if [userId] is `null`).
  /// - [UnauthorizedException] if authentication is required and missing/invalid.
  /// - [ForbiddenException] if the authenticated user lacks permission.
  /// - [ServerException] for general server-side errors (5xx).
  /// - [NetworkException] for connectivity issues.
  /// - [UnknownException] for other unexpected errors during the HTTP call.
  /// Can also throw other exceptions during serialization/deserialization.
  Future<SuccessApiResponse<T>> update({
    required String id,
    required T item,
    String? userId,
  });

  /// Deletes a resource item identified by [id].
  ///
  /// - [userId]: The unique identifier of the user performing the operation.
  ///   If `null`, the operation may be considered a global delete (e.g.,
  ///   by an admin), depending on the resource type [T]. Implementations
  ///   must handle the `null` case appropriately.
  /// - [id]: The unique identifier of the resource item to delete.
  ///
  /// Implementations should handle the request to remove the item with the
  /// given [id] (typically via DELETE `endpoint/{id}`), potentially scoped
  /// by the provided [userId].
  /// Returns `void` upon successful deletion.
  ///
  /// Throws [HtHttpException] or its subtypes on failure:
  /// - [NotFoundException] if no item exists with the given [id] (scoped by user
  ///   if [userId] is provided, or globally if [userId] is `null`).
  /// - [UnauthorizedException] if authentication is required and missing/invalid.
  /// - [ForbiddenException] if the authenticated user lacks permission.
  /// - [ServerException] for general server-side errors (5xx).
  /// - [NetworkException] for connectivity issues.
  /// - [UnknownException] for other unexpected errors during the HTTP call.
  Future<void> delete({required String id, String? userId});
}
