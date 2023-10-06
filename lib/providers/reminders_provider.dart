import 'package:cloud_firestore/cloud_firestore.dart';

import '../state/reminder.dart';

typedef ReminderId = String;

sealed class _DocumentKeys {
  static const text = 'text';
  static const creationDate = 'creation_date';
  static const isDone = 'is_done';
}

abstract interface class RemindersProvider {
  Future<void> deleteReminderWithId(
    ReminderId id, {
    required String userId,
  });

  Future<void> deleteAllDocuments({
    required String userId,
  });

  Future<ReminderId> createReminder({
    required String userId,
    required String text,
    required DateTime creationDate,
  });

  Future<void> modify({
    required String reminderId,
    required bool isDone,
    required String userId,
  });

  Future<Iterable<Reminder>> loadReminders({
    required String userId,
  });
}

class FirestoreRemindersProvider implements RemindersProvider {
  @override
  Future<ReminderId> createReminder({
    required String userId,
    required String text,
    required DateTime creationDate,
  }) async {
    final creationDate = DateTime.now();
    final firebaseReminder =
        await FirebaseFirestore.instance.collection(userId).add(
      {
        _DocumentKeys.text: text,
        _DocumentKeys.creationDate: creationDate.toIso8601String(),
        _DocumentKeys.isDone: false,
      },
    );
    return firebaseReminder.id;
  }

  @override
  Future<void> deleteAllDocuments({required String userId}) async {
    final store = FirebaseFirestore.instance;
    final operation = store.batch();
    final collection = await store.collection(userId).get();
    for (final document in collection.docs) {
      operation.delete(document.reference);
    }
    // delete all reminders for this user on Firestore,
    await operation.commit();
  }

  @override
  Future<void> deleteReminderWithId(
    ReminderId id, {
    required String userId,
  }) async {
    final collection =
        await FirebaseFirestore.instance.collection(userId).get();

    // delete from Firebase
    final firebaseReminder = collection.docs.firstWhere(
      (element) => element.id == id,
    );
    await firebaseReminder.reference.delete();
  }

  @override
  Future<Iterable<Reminder>> loadReminders({
    required String userId,
  }) async {
    final collection =
        await FirebaseFirestore.instance.collection(userId).get();

    final reminders = collection.docs.map(
      (doc) => Reminder(
        id: doc.id,
        text: doc[_DocumentKeys.text] as String,
        isDone: doc[_DocumentKeys.isDone] as bool,
        creationDate: DateTime.parse(doc[_DocumentKeys.creationDate] as String),
      ),
    );

    return reminders;
  }

  @override
  Future<void> modify({
    required String reminderId,
    required bool isDone,
    required String userId,
  }) async {
    //update remote
    final collection =
        await FirebaseFirestore.instance.collection(userId).get();
    final firebaseReminder = collection.docs
        .where((element) => element.id == reminderId)
        .first
        .reference;

    await firebaseReminder.update({
      _DocumentKeys.isDone: isDone,
    });
  }
}
