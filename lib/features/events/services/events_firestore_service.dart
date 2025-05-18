import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:educonnect/features/events/model/event_model.dart';

class EventsFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _eventsCollection = 'events';

  // Get all events
  Stream<List<EventModel>> getEventsStream() {
    return _firestore
        .collection(_eventsCollection)
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Add document ID to the data
        return EventModel.fromJson(data);
      }).toList();
    });
  }

  // Get events by category
  Stream<List<EventModel>> getEventsByCategoryStream(String category) {
    return _firestore
        .collection(_eventsCollection)
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) {
      List<EventModel> events = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Add document ID to the data
        return EventModel.fromJson(data);
      }).toList();

      // Sort the events by date in the app instead of in the query
      events.sort((a, b) => a.date.compareTo(b.date));
      return events;
    });
  }

  // Add a new event
  Future<void> addEvent(EventModel event) async {
    try {
      // Convert DateTime to Timestamp for Firestore
      Map<String, dynamic> eventData = event.toJson();
      // Make sure we're storing as Timestamp, not String
      eventData['date'] = Timestamp.fromDate(event.date);

      await _firestore
          .collection(_eventsCollection)
          .doc(event.id)
          .set(eventData);
    } catch (e) {
      print('Error adding event: $e');
      rethrow;
    }
  }

  // Update an event
  Future<void> updateEvent(EventModel event) async {
    try {
      // Convert DateTime to Timestamp for Firestore
      Map<String, dynamic> eventData = event.toJson();
      // Make sure we're storing as Timestamp, not String
      eventData['date'] = Timestamp.fromDate(event.date);

      await _firestore
          .collection(_eventsCollection)
          .doc(event.id)
          .update(eventData);
    } catch (e) {
      print('Error updating event: $e');
      rethrow;
    }
  }

  // Delete an event
  Future<void> deleteEvent(String eventId) async {
    try {
      await _firestore.collection(_eventsCollection).doc(eventId).delete();
    } catch (e) {
      print('Error deleting event: $e');
      rethrow;
    }
  }

  // Join an event (update participants count)
  Future<void> joinEvent(String eventId) async {
    try {
      await _firestore.collection(_eventsCollection).doc(eventId).update({
        'participants': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error joining event: $e');
      rethrow;
    }
  }

  // Leave an event (update participants count)
  Future<void> leaveEvent(String eventId) async {
    try {
      await _firestore.collection(_eventsCollection).doc(eventId).update({
        'participants': FieldValue.increment(-1),
      });
    } catch (e) {
      print('Error leaving event: $e');
      rethrow;
    }
  }
}
