<div align="center">
  <img src="https://avatars.githubusercontent.com/u/202675624?s=400&u=dc72a2b53e8158956a3b672f8e52e39394b6b610&v=4" alt="Flutter News App Toolkit Logo" width="220">
  <h1>Data Client</h1>
  <p><strong>The essential generic data access interfaces for the Flutter News App Toolkit.</strong></p>
</div>

<p align="center">
  <img src="https://img.shields.io/badge/coverage-100%25-green?style=for-the-badge" alt="coverage: xx%">
<a href="https://flutter-news-app-full-source-code.github.io/docs/"><img src="https://img.shields.io/badge/LIVE_DOCS-VIEW-slategray?style=for-the-badge" alt="Live Docs: View"></a>
<a href="https://github.com/flutter-news-app-full-source-code"><img src="https://img.shields.io/badge/MAIN_PROJECT-BROWSE-purple?style=for-the-badge" alt="Main Project: Browse"></a>
</p>

This `data_client` package serves as a foundational shared library for the [**Flutter News App Full Source Code Toolkit**](https://github.com/flutter-news-app-full-source-code). It defines a generic, abstract interface (`DataClient<T>`) for interacting with data resources of type `T`. This interface is designed to handle operations for *both* user-scoped resources (where data is specific to a user) and global resources (where data is not tied to a specific user, e.g., admin-managed content). The optional `userId` parameter in methods is used to differentiate between these two use cases.

While its core focus is on providing a standardized contract for common data access patterns, including standard CRUD (Create, Read, Update, Delete) operations, the interface is designed to be extensible to support additional resource-specific methods. It establishes a contract for data clients, expecting implementations to handle underlying communication (like HTTP) and manage serialization/deserialization. This package is designed to be implemented by concrete client classes that interact with specific data sources or APIs.

## ⭐ Feature Showcase: The Foundation for Robust Data Interaction

This package provides the critical interface for consistent and flexible data access across the entire news application ecosystem.

<details>
<summary><strong>🧱 Generic & Extensible Data Access</strong></summary>

### 🌐 Core Data Client Interface (`DataClient<T>`)
- **`create({String? userId, required T item})`**: Create a new resource. If `userId` is null, may represent a global creation.
- **`read({String? userId, required String id})`**: Read a single resource by ID. If `userId` is null, reads a global resource.
- **`readAll({String? userId, Map<String, dynamic>? filter, PaginationOptions? pagination, List<SortOption>? sort})`**: Reads multiple resources with powerful filtering, sorting, and pagination.
- **`update({String? userId, required String id, required T item})`**: Update an existing resource by ID. If `userId` is null, updates a global resource.
- **`delete({String? userId, required String id})`**: Delete a resource by ID. If `userId` is null, deletes a global resource.
- **`count({String? userId, Map<String, dynamic>? filter})`**: Efficiently counts resources matching a filter without fetching them.
- **`aggregate({String? userId, required List<Map<String, dynamic>> pipeline})`**: Executes a complex, server-side aggregation pipeline for analytics and reporting.

### ⚙️ Advanced Capabilities
- **Support for User-Scoped and Global Data:** The optional `userId` parameter allows a single client implementation to handle data specific to a user or data that is globally accessible.
- **Advanced Pagination and Sorting:** Supports robust, cursor-based pagination (via `PaginationOptions`) and multi-field sorting (`List<SortOption>`), ideal for document databases.
- **Rich Querying Capability:** The `readAll` method accepts a `filter` map that can be used to construct complex, MongoDB-style queries.
- **Type Safety:** Uses generics (`<T>`) to work with any data model.
- **Serialization Agnostic:** Defines `FromJson<T>` and `ToJson<T>` typedefs, allowing implementations to use their preferred serialization logic.
- **Standardized Error Handling:** Specifies expected `HttpException` subtypes (from `package:core`) that implementations should throw on failure.

> **💡 Your Advantage:** You get a meticulously designed, production-quality data access interface that forms the backbone of a scalable news platform. This package ensures consistent data interaction patterns, saving months of development time and ensuring architectural consistency across your mobile app, web dashboard, and backend API.

</details>

## 🔑 Licensing

This `data_client` package is an integral part of the [**Flutter News App Full Source Code Toolkit**](https://github.com/flutter-news-app-full-source-code). For comprehensive details regarding licensing, including trial and commercial options for the entire toolkit, please refer to the main toolkit organization page.
