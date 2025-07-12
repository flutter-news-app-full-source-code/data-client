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

  /// Reads multiple resource items of type [T], with support for rich filtering,
  /// sorting, and pagination.
  ///
  /// This method provides a flexible and powerful query interface suitable for
  /// document databases like MongoDB, consolidating previous `readAll` and
  /// `readAllByQuery` functionalities.
  ///
  /// - [userId]: The unique identifier of the user. If `null`, retrieves
  ///   *global* resources. If provided, retrieves resources scoped to that user.
  /// - [filter]: An optional map defining the query conditions. It is designed
  ///   to be compatible with MongoDB's query syntax. If `null` or empty, all
  ///   resources (scoped by `userId`) are returned.
  /// - [pagination]: Optional pagination parameters, including `cursor` and `limit`.
  /// - [sort]: An optional list of [SortOption] to define the sorting order.
  ///   MongoDB supports sorting by multiple fields.
  ///
  /// Returns a [SuccessApiResponse] containing a [PaginatedResponse] with the
  /// list of deserialized items and a `nextCursor` for the next page.
  ///
  /// **Example Filter (MongoDB-style):**
  /// ```dart
  /// {
  ///   'status': 'published',
  ///   'tags': { '\$in': ['tech', 'dart'] },
  ///   'publishDate': { '\$gte': '2024-01-01T00:00:00.000Z' }
  /// }
  /// ```
  ///
  /// **Example Sort:**
  /// ```dart
  /// [
  ///   SortOption('publishDate', SortOrder.desc),
  ///   SortOption('title', SortOrder.asc),
  /// ]
  /// ```
  ///
  /// Throws [HtHttpException] or its subtypes on failure:
  /// - [BadRequestException] for invalid filter, sort, or pagination parameters.
  /// - [UnauthorizedException] if authentication is required and missing/invalid.
  /// - [ForbiddenException] if the authenticated user lacks permission.
  /// - [ServerException] for general server-side errors (5xx).
  /// - [NetworkException] for connectivity issues.
  /// - [UnknownException] for other unexpected errors.
  Future<SuccessApiResponse<PaginatedResponse<T>>> readAll({
    String? userId,
    Map<String, dynamic>? filter,
    PaginationOptions? pagination,
    List<SortOption>? sort,
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

  /// Counts the number of resource items matching the given criteria.
  ///
  /// This method provides an efficient way to get the total number of documents
  /// without fetching the documents themselves, which is ideal for UI elements
  /// like badges or for backend analytics.
  ///
  /// - [userId]: The unique identifier of the user. If `null`, counts
  ///   *global* resources. If provided, counts resources scoped to that user.
  /// - [filter]: An optional map defining the query conditions, compatible with
  ///   MongoDB's query syntax. If `null` or empty, all resources (scoped by
  ///   `userId`) are counted.
  ///
  /// Returns a [SuccessApiResponse] containing the total count as an integer.
  ///
  /// Throws [HtHttpException] or its subtypes on failure:
  /// - [BadRequestException] for invalid filter parameters.
  /// - [UnauthorizedException] if authentication is required and missing/invalid.
  /// - [ForbiddenException] if the authenticated user lacks permission.
  /// - [ServerException] for general server-side errors (5xx).
  /// - [NetworkException] for connectivity issues.
  /// - [UnknownException] for other unexpected errors.
  Future<SuccessApiResponse<int>> count({
    String? userId,
    Map<String, dynamic>? filter,
  });
}
