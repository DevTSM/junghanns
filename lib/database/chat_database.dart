import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/chat/chat_model.dart';
import '../models/chat/info_model.dart';
import '../models/chat/message_model.dart';
import '../preferences/global_variables.dart';

class ChatDatabaseHelper {
  static Database? _database;
  static const String _dbName = 'chat_database.db';

  // Obtener la instancia de la base de datos
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Inicializar la base de datos
  /*Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }*/
  // En la función _initDatabase, incrementamos la versión de la base de datos
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    print('Inicializa base de datos');
    return await openDatabase(path, version: 9, onCreate: _createDB, onUpgrade: _onUpgrade);
  }

// Función que maneja las actualizaciones de la base de datos
  /*Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('Agrega el nuevo campo isCheck');
    if (oldVersion < 3) {
      // Si la base de datos está en una versión antigua, se debe agregar la nueva columna
      // Si la base de datos está en una versión antigua, se debe agregar la nueva columna
      await db.execute('''ALTER TABLE messages ADD COLUMN isCheck INTEGER DEFAULT 0;''');
      *//*await db.execute('''
      ALTER TABLE messages ADD COLUMN isSent INTEGER DEFAULT 0;
    ''');*//*
    }
  }*/
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('Actualizando base de datos de la versión $oldVersion a $newVersion');
    if (oldVersion < 9) {
      // Eliminar las tablas existentes
      await db.execute('DROP TABLE IF EXISTS chats');
      await db.execute('DROP TABLE IF EXISTS messages');

      // Volver a crear las tablas
      await _createDB(db, newVersion);
    }
  }


  // Crear las tablas
  Future<void> _createDB(Database db, int version) async {
    // Crear tabla de chats
    await db.execute('''
      CREATE TABLE chats (
        chatId TEXT PRIMARY KEY,
        createdAt INTEGER NOT NULL,
        status TEXT NOT NULL,
        statusText TEXT NOT NULL,
        lastMessage INTEGER NOT NULL
      )
    ''');

    // Crear tabla de mensajes
    await db.execute('''
      CREATE TABLE messages (
        messageId TEXT PRIMARY KEY,
        chatId TEXT NOT NULL,
        registeredAt INTEGER NOT NULL,
        message TEXT NOT NULL,
        type TEXT NOT NULL,
        typeText TEXT NOT NULL,
        user TEXT NOT NULL,
        employee TEXT NOT NULL,
        received INTEGER NOT NULL,  -- Almacena 'received' como entero (0 o 1)
        read INTEGER NOT NULL,      -- Almacena 'read' como entero (0 o 1)
        isCheck INTEGER NOT NULL,   -- Almacena 'check' como entero (0 o 1)
        isSent INTEGER DEFAULT 0,   -- Asegúrate de incluir esta columna
        FOREIGN KEY (chatId) REFERENCES chats (chatId) ON DELETE CASCADE
      )
    ''');
  }

  // Insertar un chat
  Future<void> insertChat(ChatModel chat) async {
    final db = await database;
    await db.insert(
      'chats',
      chat.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /*// Insertar un mensaje
  Future<void> insertMessage(MessageModel message, String chatId) async {
    final db = await database;
    await db.insert(
      'messages',
      {
        'messageId': message.messageId,
        'chatId': chatId, // Relación con el chat
        'registeredAt': message.registeredAt,
        'message': message.message,
        'type': message.type,
        'typeText': message.typeText,
        'user': message.user,
        'employee': message.employee,
        'received': message.info.received ? 1 : 0, // Convertir a 1 o 0
        'read': message.info.read ? 1 : 0,         // Convertir a 1 o 0
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
*/
  /*// Insertar un mensaje
  Future<void> insertMessage(MessageModel message, String chatId, {bool isSent = false, bool isCheck = false}) async {
    final db = await database;
    await db.insert(
      'messages',
      {
        'messageId': message.messageId,
        'chatId': chatId, // Relación con el chat
        'registeredAt': message.registeredAt,
        'message': message.message,
        'type': message.type,
        'typeText': message.typeText,
        'user': message.user,
        'employee': message.employee,
        'received': message.info.received ? 1 : 0, // Convertir a 1 o 0
        'read': message.info.read ? 1 : 0,         // Convertir a 1 o 0
        'isCheck': isCheck ? 1 : 0,
        'isSent': isSent ? 1 : 0,  // Nuevo campo que indica si el mensaje ha sido enviado
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }*/
  Future<void> insertMessage(MessageModel message, String chatId, {bool isSent = false}) async {
    final db = await database;

    // Verificar si ya existe un mensaje con el mismo ID
    final List<Map<String, dynamic>> existingMessages = await db.query(
      'messages',
      where: 'messageId = ?',
      whereArgs: [message.messageId],
    );

    if (existingMessages.isNotEmpty) {
      // Si el mensaje ya existe, no lo insertamos
      print('El mensaje con ID ${message.messageId} ya existe y no será insertado.');
      return;
    }

    // Insertar solo si no existe
    await db.insert(
      'messages',
      {
        'messageId': message.messageId,
        'chatId': chatId,
        'registeredAt': message.registeredAt,
        'message': message.message,
        'type': message.type,
        'typeText': message.typeText,
        'user': message.user,
        'employee': message.employee,
        'received': message.info.received ? 1 : 0,
        'read': message.info.read ? 1 : 0,
        'isCheck': message.isCheck,
        'isSent': isSent ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace, // Opcional, ya que evitamos duplicados antes
    );
  }

  // Obtener todos los chats
  Future<List<ChatModel>> getChats() async {
    final db = await database;
    final List<Map<String, dynamic>> chatMaps = await db.query('chats');

    List<ChatModel> chats = [];

    for (var chatMap in chatMaps) {
      final List<Map<String, dynamic>> messageMaps = await db.query(
        'messages',
        where: 'chatId = ?',
        whereArgs: [chatMap['chatId']],
      );

      List<MessageModel> messages = messageMaps.map((msg) {
        return MessageModel(
          messageId: msg['messageId'],
          registeredAt: msg['registeredAt'],
          message: msg['message'],
          type: msg['type'],
          typeText: msg['typeText'],
          user: msg['user'],
          employee: msg['employee'],
          info: InfoModel(
            received: msg['received'] == 1, // Convertir 1 a `true` y 0 a `false`
            read: msg['read'] == 1,         // Convertir 1 a `true` y 0 a `false`
          ),
          isCheck: msg['isCheck'] == 1,         // Convertir 1 a `true` y 0 a `false` para el campo check
        );
      }).toList();

      chats.add(ChatModel(
        chatId: chatMap['chatId'],
        createdAt: chatMap['createdAt'],
        status: chatMap['status'],
        statusText: chatMap['statusText'],
        lastMessage: chatMap['lastMessage'],
        messages: messages,
      ));
    }

    return chats;
  }

  // Obtener un chat por su ID
  Future<ChatModel?> getChatById(String chatId) async {
    final db = await database;
    final List<Map<String, dynamic>> chatMaps = await db.query(
      'chats',
      where: 'chatId = ?',
      whereArgs: [chatId],
    );

    if (chatMaps.isEmpty) return null;

    final chatMap = chatMaps.first;
    final List<Map<String, dynamic>> messageMaps = await db.query(
      'messages',
      where: 'chatId = ?',
      whereArgs: [chatId],
    );

    List<MessageModel> messages = messageMaps.map((msg) {
      return MessageModel(
        messageId: msg['messageId'],
        registeredAt: msg['registeredAt'],
        message: msg['message'],
        type: msg['type'],
        typeText: msg['typeText'],
        user: msg['user'],
        employee: msg['employee'],
        info: InfoModel(
          received: msg['received'] == 1,
          read: msg['read'] == 1,
        ),
        isCheck: msg['isCheck'] == 1,         // Convertir 1 a `true` y 0 a `false` para el campo check
      );
    }).toList();

    return ChatModel(
      chatId: chatMap['chatId'],
      createdAt: chatMap['createdAt'],
      status: chatMap['status'],
      statusText: chatMap['statusText'],
      lastMessage: chatMap['lastMessage'],
      messages: messages,
    );
  }

  // Eliminar un chat
  Future<void> deleteChat(String chatId) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('messages', where: 'chatId = ?', whereArgs: [chatId]);
      await txn.delete('chats', where: 'chatId = ?', whereArgs: [chatId]);
    });
  }

  // Eliminar un mensaje
  Future<void> deleteMessage(String messageId) async {
    final db = await database;
    await db.delete(
      'messages',
      where: 'messageId = ?',
      whereArgs: [messageId],
    );
  }

  /*// Obtener todos los chats con mensajes locales
  Future<List<ChatModel>> getLocalMessages() async {
    final db = await database;
    final List<Map<String, dynamic>> chatMaps = await db.query('chats');
    print("Chats encontrados: ${chatMaps.length}");

    List<ChatModel> chatModels = [];
    for (var chatMap in chatMaps) {
      final List<Map<String, dynamic>> messageMaps = await db.query(
        'messages',
        where: 'chatId = ?',
        whereArgs: [chatMap['chatId']],
      );
      print("Mensajes encontrados para el chat ${chatMap['chatId']}: ${messageMaps.length}");

      if (messageMaps.isEmpty) {
        print("No se encontraron mensajes para el chat ${chatMap['chatId']}");
      }

      List<MessageModel> messages = messageMaps.map((msg) {
        return MessageModel(
          messageId: msg['messageId'],
          registeredAt: msg['registeredAt'],
          message: msg['message'],
          type: msg['type'],
          typeText: msg['typeText'],
          user: msg['user'],
          employee: msg['employee'],
          info: InfoModel(
            received: msg['received'] == 1, // Convertir 1 a `true` y 0 a `false`
            read: msg['read'] == 1,         // Convertir 1 a `true` y 0 a `false`
          ),
        );
      }).toList();

      chatModels.add(ChatModel(
        chatId: chatMap['chatId'],
        createdAt: chatMap['createdAt'],
        status: chatMap['status'],
        statusText: chatMap['statusText'],
        lastMessage: chatMap['lastMessage'],
        messages: messages,
      ));
    }

    print("Se encontraron ${chatModels.length} chats locales.");
    return chatModels;
  }*/
// Obtener todos los chats con mensajes locales
  Future<List<ChatModel>> getLocalMessages() async {
    final db = await database;
    final List<Map<String, dynamic>> chatMaps = await db.query('chats');
    print("Chats encontrados: ${chatMaps.length}");

    List<ChatModel> chatModels = [];
    for (var chatMap in chatMaps) {
      final List<Map<String, dynamic>> messageMaps = await db.query(
        'messages',
        where: 'chatId = ?',
        whereArgs: [chatMap['chatId']],
      );
      print("Mensajes encontrados para el chat ${chatMap['chatId']}: ${messageMaps.length}");

      if (messageMaps.isEmpty) {
        print("No se encontraron mensajes para el chat ${chatMap['chatId']}");
      }

      // Mapeamos los mensajes a MessageModel
      List<MessageModel> messages = messageMaps.map((msg) {
        final message = MessageModel(
          messageId: msg['messageId'],
          registeredAt: msg['registeredAt'],  // Asegúrate de que 'registeredAt' es un timestamp en milisegundos
          message: msg['message'],
          type: msg['type'],
          typeText: msg['typeText'],
          user: msg['user'],
          employee: msg['employee'],
          info: InfoModel(
            received: msg['received'] == 1,  // Convertir 1 a `true` y 0 a `false`
            read: msg['read'] == 1,          // Convertir 1 a `true` y 0 a `false`
          ),
          isCheck: msg['isCheck'] == 1,         // Convertir 1 a `true` y 0 a `false` para el campo check
        );
        print("Mensaje guardado: ${message.toString()}"); // Imprimir el mensaje
        return message;
      }).toList();

      // Ordenar los mensajes en orden descendente (más recientes primero)
      messages.sort((a, b) => b.registeredAt.compareTo(a.registeredAt));

      // Crear el chat con los mensajes ordenados
      final chat = ChatModel(
        chatId: chatMap['chatId'],
        createdAt: chatMap['createdAt'],
        status: chatMap['status'],
        statusText: chatMap['statusText'],
        lastMessage: chatMap['lastMessage'],
        messages: messages,
      );
      print("Chat guardado: ${chat.toString()}"); // Imprimir el chat
      chatModels.add(chat);
    }

    print("Se encontraron ${chatModels.length} chats locales.");
    return chatModels;
  }

  // Obtener todos los mensajes pendientes (no enviados)
  /*Future<List<MessageModel>> getPendingMessages() async {
    final dbHelper = ChatDatabaseHelper();
    List<MessageModel> pendingMessages = await dbHelper.getPendingMessages();

    print("Mensajes pendientes recuperados: $pendingMessages"); // Verifica los mensajes que se recuperan
    return pendingMessages;
  }*/
  // Obtener todos los mensajes pendientes (no enviados)
  Future<List<MessageModel>> getPendingMessages() async {
    final db = await database;
    final List<Map<String, dynamic>> messageMaps = await db.query(
      'messages',
      where: 'isSent = ?',
      whereArgs: [0],  // Filtra los mensajes con isSent = 0
    );

    List<MessageModel> pendingMessages = messageMaps.map((msg) {
      return MessageModel(
        messageId: msg['messageId'],
        registeredAt: msg['registeredAt'],
        message: msg['message'],
        type: msg['type'],
        typeText: msg['typeText'],
        user: msg['user'],
        employee: msg['employee'],
        info: InfoModel(
          received: msg['received'] == 1,  // Convertir 1 a `true` y 0 a `false`
          read: msg['read'] == 1,          // Convertir 1 a `true` y 0 a `false`
        ),
        isCheck: msg['isCheck'] == 1,         // Convertir 1 a `true` y 0 a `false` para el campo check
      );
    }).toList();

    print("Mensajes pendientes recuperados: $pendingMessages");
    return pendingMessages;
  }



  Future<void> updateMessageSentStatus(String messageId, bool isSent) async {
    final db = await database;
    await db.update(
      'messages',
      {'isSent': isSent ? 1 : 0},
      where: 'messageId = ?',
      whereArgs: [messageId],
    );
  }

// Actualizar el estado de envío de un mensaje
  Future<void> updateMessageStatus(String messageId,  {required bool isSent}) async {
    final db = await database;
    await db.update(
      'messages',
      {'isSent': isSent ? 1 : 0},
      where: 'messageId = ?',
      whereArgs: [messageId],
    );
  }

  Future<void> checkAndClearChatDatabase() async {
    print('Entre a limpiar las tablas');
    final db = await database;

    // Obtener el ID del chat almacenado en la base de datos
    final List<Map<String, dynamic>> result = await db.query('chats', columns: ['chatId']);

    if (result.isNotEmpty) {
      final localChatId = result.first['chatId'];

      if (prefs.idChat != null && localChatId != prefs.idChat) {
        // Los IDs son diferentes, limpiar las tablas
        await db.delete('messages');
        await db.delete('chats');
        print('Las tablas de chats y mensajes fueron limpiadas porque el chatId cambió.');
      }
    }
  }



}