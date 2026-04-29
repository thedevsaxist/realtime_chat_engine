# Architecture Overview

This Flutter app is organized around a simple Riverpod + Clean-ish layering:

- **Presentation**: Screens + Riverpod `StateNotifier`s (controllers)
- **Domain**: Entities + repository interfaces
- **Data**: API clients, websocket client, sqlite DAOs/databases, and DTO models
- **Core**: Networking setup (Dio + interceptors), constants, and shared sqlite database helper

The main user journeys are **Login** and **Realtime Chat (per conversation)**.

## 1) Layering

### Presentation (UI + State)

Riverpod providers expose app state to widgets:

- App shell / navigation:
  - `lib/main.dart`
  - `MyApp` watches `authControllerProvider`
  - If authenticated -> `HomeScreen`
  - If unauthenticated -> `LoginScreen`
  - Route `/chat` builds `ChatScreen(conversationId: ...)`

- Auth:
  - `lib/features/auth/presentation/screens/login_screen.dart`
  - `lib/features/auth/presentation/controller/auth_controller.dart`

- Home (conversation list):
  - `lib/features/home/presentation/screens/home_screen.dart`
  - `lib/features/home/presentation/controller/home_controller.dart`

- Chat (messages for a conversation):
  - `lib/features/home/presentation/screens/chat_screen.dart`
  - `lib/features/home/presentation/controller/chat_controller.dart`

### Domain (Entities + Repository contracts)

- Auth domain:
  - `lib/features/auth/domain/entities/login_req_entity.dart`
  - `lib/features/auth/domain/entities/login_res_entity.dart`
  - `lib/features/auth/domain/repository/auth_repository.dart`

- Chat domain:
  - `lib/features/home/domain/entities/*`
  - `lib/features/home/domain/repositories/chat_repository.dart`

### Data (Implementations + DTOs)

- Auth data sources:
  - REST client: `lib/features/auth/data/data_source/auth_client.dart`
  - Local persistence: `lib/features/auth/data/data_source/auth_local_storage.dart`
  - Token storage (encrypted): `lib/features/auth/data/data_source/auth_secure_storage.dart`
  - Repository implementation: `lib/features/auth/data/repository/auth_repository_impl.dart`

- Chat data sources:
  - REST client: `lib/features/home/data/data_source/chat_client.dart`
  - Websocket client: `lib/features/home/data/data_source/chat_web_socket.dart`
  - Local sqlite storage: `lib/features/home/data/data_source/chat_database.dart`
  - Repository implementation: `lib/features/home/data/repos/chat_repository_impl.dart`

- SQLite schema / DB helper:
  - `lib/core/shared/database_helper.dart`

### Core (Cross-cutting)

- Dio + interceptors + base URL:
  - `lib/core/config/network/dio_service.dart`
  - `lib/core/config/network/interceptiors/logging_interceptor.dart`
  - `lib/core/config/network/interceptiors/auth_interceptors.dart`
  - `lib/core/shared/constants.dart` (pulls `BASEURL` and `AUTH_DB_PASSWORD` from `.env`)

## 2) Riverpod provider wiring (dependency graph)

### Core networking providers

- `dioServiceProvider` (`lib/core/config/network/dio_service.dart`)
  - Constructs a `Dio` with:
    - `baseUrl: Constants.baseUrl`
    - `LoggingInterceptor`
    - `AuthInterceptor`

- `AuthInterceptor` (`lib/core/config/network/interceptiors/auth_interceptors.dart`)
  - On each request, reads token from `auth_secure_storage` and sets header:
    - `options.headers = {"Auth": token}`

### Auth providers

- `authSecureStorageProvider` (`lib/features/auth/data/data_source/auth_secure_storage.dart`)
  - Encrypted sqlite (`auth.db`) with table `auth(token TEXT)`

- `authLocalStorageProvider` (`lib/features/auth/data/data_source/auth_local_storage.dart`)
  - Uses shared sqlite `app.db` to read/write table `users`

- `authClientProvider` (`lib/features/auth/data/data_source/auth_client.dart`)
  - Uses `dioServiceProvider` and calls:
    - `POST /auth/login`

- `conversationDaoProvider` (`lib/features/home/data/data_source/conversation_database.dart`)
  - Uses `app.db` to manage:
    - `conversations`
    - `user_conversations`

- `authRepositoryProvider` (`lib/features/auth/data/repository/auth_repository_impl.dart`)
  - `AuthRepositoryImpl(authClient, authLocalStorage, authSecureStorage, conversationDao)`

- `authControllerProvider` (`lib/features/auth/presentation/controller/auth_controller.dart`)
  - `AuthController`:
    - Calls `AuthRepository.login(...)`
    - On logout: clears cached chat and invalidates itself

### Home providers

- `homeControllerProvider` (`lib/features/home/presentation/controller/home_controller.dart`)
  - `HomeController` loads:
    - Current user from `AuthLocalStorage`
    - Conversations from `ConversationDao` (JOIN)
    - Messages per conversation from `ChatRepository`

### Chat providers

- `chatRepositoryProvider` (`lib/features/home/data/repos/chat_repository_impl.dart`)
  - `ChatRepositoryImpl(chatClient, chatDatabase, chatWebSocket)`

- `chatWebSocketProvider` (`lib/features/home/data/data_source/chat_web_socket.dart`)
  - Provides a `ChatWebSocket` instance

- `chatDatabaseProvider` (`lib/features/home/data/data_source/chat_database.dart`)
  - Provides sqlite-backed message storage (`ChatDatabase`)

- `chatControllerProvider(conversationId)` (`lib/features/home/presentation/controller/chat_controller.dart`)
  - Builds `ChatController(ref, conversationId)` which:
    - loads cached/remote messages via `ChatRepository.getMessages`
    - connects websocket via `ChatWebSocket.connect(conversationId)`
    - supports `sendMessage` and `deleteMessage`

## 3) End-to-end flows

## A) App start + auth gate

1. `main()` loads `.env` and runs `ProviderScope(child: MyApp())` (`lib/main.dart`)
2. `MyApp.build()` watches `authControllerProvider` and switches:
   - `Authenticated` -> `HomeScreen`
   - `UnAuthenticated` -> `LoginScreen`

There is no auto-refresh of auth state shown here; the initial `AuthController` state is `UnAuthenticated`.

## B) Login flow

1. `LoginScreen` calls:
   - `ref.read(authControllerProvider.notifier).login(userId, password)`
   (`lib/features/auth/presentation/screens/login_screen.dart`)
2. `AuthController.login(...)` calls domain:
   - `_authRepository.login(LoginReqEntity(...))`
   (`lib/features/auth/presentation/controller/auth_controller.dart`)
3. `AuthRepositoryImpl.login(...)` calls the REST API:
   - `_authClient.login(reqEntity.toModel())`
   (`lib/features/auth/data/repository/auth_repository_impl.dart`)
4. `AuthClient.login(...)` uses Dio:
   - `dioService.dio.post("/auth/login", data: reqModel.toJson())`
   (`lib/features/auth/data/data_source/auth_client.dart`)
5. After a successful token response:
   - `AuthRepositoryImpl`:
     - Saves `User` into `users` table via `AuthLocalStorage.saveUser`
     - Saves token via `AuthSecureStorage.saveToken`
     - Links `userId` <-> `conversationId` via `ConversationDao.linkUserToConversation`

6. `AuthController` updates UI state to:
   - `Authenticated(userId, token)`

## C) Home (conversation list) flow

1. `HomeScreen` watches `homeControllerProvider` (`lib/features/home/presentation/screens/home_screen.dart`)
2. `HomeController._init()`:
   - reads user via `AuthLocalStorage.getUser()`
   - reads conversations via `ConversationDao.getUserConversations(user.id)`
   - for each conversation:
     - `chatRepository.getMessages(conv.id)`
3. `ChatRepositoryImpl.getMessages(conversationId)`:
   - Checks local cache first:
     - `cachedMessages = chatRoom.getMessages(conversationId)` where `chatRoom` is `ChatDatabase`
   - If cache is empty:
     - Calls REST:
       - `chatClient.getMessages(conversationId)` -> `/messages?conversationId=...`
     - Converts DTO to entity:
       - `GetMessagesResEntity.fromModel(...)`
     - Persists each message locally:
       - `chatRoom.addMessage(message)`
   - Returns a `GetMessagesResEntity` with `data: {"messages": cachedMessages}`

4. `HomeScreen` renders `state.conversations` as a list.

## D) Chat (messages + send/delete) flow

### Chat open

1. `MyApp` route `/chat` creates:
   - `ChatScreen(conversationId: ...)` (`lib/main.dart`)
2. `ChatScreen` watches:
   - `chatControllerProvider(widget.conversationId)`
   (`lib/features/home/presentation/screens/chat_screen.dart`)
3. `ChatController._init()` attempts to:
   - load current user (`_authLocalStorage?.getUser()`)
   - load messages (`chatRepository.getMessages(conversationId)`)
   - update controller state with:
     - `state = state.copyWith(messages: messages, user: user)`
   - connect websocket:
     - `_chatWebSocket.connect(conversationId)`

### Send message

1. User taps send icon in `ChatScreen`
2. `ChatScreen` calls:
   - `ref.read(chatControllerProvider(widget.conversationId).notifier).sendMessage(messageController.text)`
3. `ChatController.sendMessage(...)`:
   - Creates a `MessageEntity` (optimistic UI update):
     - `id: Uuid().v4()`
     - `senderId: _userId!`
     - `conversationId: conversationId`
     - `createdAt: DateTime.now().toIso8601String()`
   - Updates state immediately:
     - `state = state.copyWith(messages: [...state.messages, payload])`
   - Persists + transmits:
     - `_chatRepository.createMessage(payload)`
4. `ChatRepositoryImpl.createMessage(...)`:
   - Saves to local sqlite:
     - `chatRoom.addMessage(message)`
   - Sends over websocket:
     - builds `CreateMessageReqEntity(...).toModel()` and calls:
       - `chatWebSocket.sendMessage(req)`
5. `ChatWebSocket.sendMessage(...)` encodes:
   - event: `"send_message"`
   - data: `{ conversationId, senderId, content }`

### Delete message

1. Long-press on a bubble triggers:
   - `chatController.deleteMessage(data.id)`
   (`lib/features/home/presentation/screens/chat_screen.dart`)
2. `ChatController.deleteMessage(...)`:
   - builds `DeleteMessagesReqEntity(conversationId, messageId)`
   - calls `_chatRepository.deleteMessages(request)`
   - invalidates provider to refresh widget
3. `ChatRepositoryImpl.deleteMessages(...)`:
   - deletes only from local sqlite:
     - `chatRoom.deleteMessage(conversationId, messageId)`
   - API deletion is currently commented out

## 4) Models / DTOs and conversions

### Auth models/entities

- Request:
  - `LoginReqEntity` <-> `LoginReqModel`
  - `LoginReqEntity.toModel()` and factory `fromModel`
- Response:
  - `LoginResModel` maps to `LoginResEntity` by extracting:
    - token
    - userId
    - `conversationIds` from `conversations[].id`

### Chat models/entities

- Message:
  - `MessageEntity` <-> `MessageModel`
  - `MessageEntity.createdAt` is stored as a string (ISO timestamp)
- Get messages:
  - `GetMessagesResModel` -> `GetMessagesResEntity`
  - Both use:
    - `data: Map<String, List<...>>`

- Websocket request:
  - `CreateMessageReqEntity` -> `CreateMessageReqModel`

## 5) Local persistence (SQLite)

### Shared database (`app.db`)

Created by `DatabaseHelper` (`lib/core/shared/database_helper.dart`):

- `users(id TEXT PRIMARY KEY)`
- `conversations(id TEXT PRIMARY KEY, createdAt INTEGER, lastMessage TEXT, lastMessageTime INTEGER)`
- `user_conversations(userId TEXT, conversationId TEXT, PRIMARY KEY(userId, conversationId))`
- `messages(id TEXT PRIMARY KEY, conversationId TEXT, senderId TEXT, content TEXT, createdAt TEXT)`

### Auth token storage (`auth.db`)

Created by `AuthSecureStorage` (`lib/features/auth/data/data_source/auth_secure_storage.dart`):

- encrypted sqlite
- table: `auth(token TEXT)`

### Chat message storage

Implemented by `ChatDatabase` (`lib/features/home/data/data_source/chat_database.dart`):

- `addMessage(...)`: inserts/replace into `messages`
- `getMessages(conversationId)`: selects `messages` where `conversationId = ?`, ordered by `createdAt`
- `deleteMessage(...)`: deletes by `(id, conversationId)`
- `clearCache()`: deletes all messages

## 6) Realtime websocket integration notes (important)

`ChatWebSocket` maintains:
- a `WebSocketChannel`
- a broadcast `StreamController<Map<String, dynamic>>` exposed as `messageStream`
- connect logic:
  - sends `"join_conversation"` event
- send logic:
  - sends `"send_message"` event with `{ conversationId, senderId, content }`

However, in the current code:
- `ChatController` calls `_chatWebSocket.connect(conversationId)` but does not subscribe to `chatWebSocket.messageStream` to update `state` with incoming server events.

So the UI relies on:
- initial message load (`getMessages`)
- optimistic local state updates on `sendMessage`

## 7) Potential gaps / inconsistencies in current wiring

These are not architectural preferences; they are based on what the code currently does:

1. **`ChatController` does not initialize `_authLocalStorage`**
   - `_authLocalStorage` is declared but never assigned from `authLocalStorageProvider`.
   - `_init()` calls: `final user = await _authLocalStorage?.getUser();`
   - This likely prevents `ChatController` from loading messages/user and prevents `_userId` from being set.

2. **Conversations table may not be populated**
   - `AuthRepositoryImpl.login()` only calls:
     - `_conversationDao.linkUserToConversation(user.id, convId)`
   - It does not insert rows into the `conversations` table (the JOIN in `getUserConversations` is an `INNER JOIN`).
   - Result: `HomeController` may end up with no conversations unless the `conversations` table is already populated elsewhere.

3. **Incoming websocket messages are not applied to controller state**
   - `ChatWebSocket.messageStream` exists, but no listener is connected in `ChatController`.

---

If you want, I can also add a small ASCII diagram of the provider graph and a “sequence diagram” style walkthrough for Login -> Home -> Chat, but the document above already maps the concrete code entry points and data flows.

