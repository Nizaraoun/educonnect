import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/event_model.dart';
import '../view/create_event_screen.dart';

class EventsController extends GetxController {
  // Observable variables
  final RxBool isLoading = false.obs;
  final RxList<EventModel> events = <EventModel>[].obs;
  final RxString selectedCategory = 'Tous'.obs;

  // Variables for event creation
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController organizerNameController = TextEditingController();
  final Rx<DateTime> eventDate = DateTime.now().obs;
  final RxString startTime = '09:00'.obs;
  final RxString endTime = '11:00'.obs;
  final RxString eventCategory = 'Académique'.obs;
  final RxBool isSubmitting = false.obs;

  // Firestore reference
  final CollectionReference eventsCollection =
      FirebaseFirestore.instance.collection('events');

  @override
  void onInit() {
    super.onInit();
    loadEvents();
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    organizerNameController.dispose();
    super.onClose();
  }

  // Load events from Firebase
  void loadEvents() {
    isLoading.value = true;
    events.clear();

    try {
      eventsCollection
          .orderBy('date', descending: false)
          .get()
          .then((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          for (var doc in snapshot.docs) {
            final data = doc.data() as Map<String, dynamic>;
            DateTime eventDate = DateTime.now();
            if (data['date'] != null) {
              if (data['date'] is Timestamp) {
                eventDate = (data['date'] as Timestamp).toDate();
              } else if (data['date'] is String) {
                eventDate = DateTime.parse(data['date']);
              }
            }

            final event = EventModel(
              id: doc.id,
              title: data['title'] ?? '',
              description: data['description'] ?? '',
              date: eventDate,
              startTime: data['startTime'] ?? '',
              endTime: data['endTime'] ?? '',
              location: data['location'] ?? '',
              category: data['category'] ?? '',
              participants: data['participants'] ?? 0,
              organizerId: data['organizerId'] ?? '',
              organizerName: data['organizerName'] ?? '',
              isUserParticipating: data['isUserParticipating'] ?? false,
            );

            events.add(event);
          }
        }
        isLoading.value = false;
      }).catchError((error) {
        print('Error fetching events: $error');
        isLoading.value = false;
        Get.snackbar(
          'Erreur',
          'Impossible de charger les événements',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      });
    } catch (e) {
      print('Exception while fetching events: $e');
      isLoading.value = false;
      Get.snackbar(
        'Erreur',
        'Une erreur s\'est produite',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Show filter options modal
  void showFilterOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filtrer les événements',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            // Filter options here
            // ...
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                },
                child: const Text('Appliquer'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Select category for filtering events
  void selectCategory(String category) {
    selectedCategory.value = category;

    if (category == 'Tous') {
      loadEvents();
    } else {
      isLoading.value = true;
      events.clear();

      eventsCollection
          .where('category', isEqualTo: category)
          .get()
          .then((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          for (var doc in snapshot.docs) {
            final data = doc.data() as Map<String, dynamic>;
            // Convert Firestore Timestamp to DateTime
            DateTime eventDate = DateTime.now();
            if (data['date'] != null) {
              if (data['date'] is Timestamp) {
                eventDate = (data['date'] as Timestamp).toDate();
              } else if (data['date'] is String) {
                eventDate = DateTime.parse(data['date']);
              }
            }

            final event = EventModel(
              id: doc.id,
              title: data['title'] ?? '',
              description: data['description'] ?? '',
              date: eventDate,
              startTime: data['startTime'] ?? '',
              endTime: data['endTime'] ?? '',
              location: data['location'] ?? '',
              category: data['category'] ?? '',
              participants: data['participants'] ?? 0,
              organizerId: data['organizerId'] ?? '',
              organizerName: data['organizerName'] ?? '',
              isUserParticipating: data['isUserParticipating'] ?? false,
            );

            events.add(event);
          }
        }
        isLoading.value = false;
      }).catchError((error) {
        print('Error filtering events: $error');
        isLoading.value = false;
      });
    }
  }

  // Navigate to create event screen
  void navigateToCreateEvent() {
    // Reset form fields
    titleController.clear();
    descriptionController.clear();
    locationController.clear();
    organizerNameController.clear();
    eventDate.value = DateTime.now();
    startTime.value = '09:00';
    endTime.value = '11:00';
    eventCategory.value = 'Académique';

    // Navigate to create event screen
    Get.to(() => const CreateEventScreen());
  }

  // Submit new event to Firebase
  void submitEvent() {
    // Validate inputs
    if (titleController.text.isEmpty) {
      Get.snackbar(
        'Erreur',
        'Veuillez saisir un titre pour l\'événement',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (descriptionController.text.isEmpty) {
      Get.snackbar(
        'Erreur',
        'Veuillez saisir une description pour l\'événement',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (locationController.text.isEmpty) {
      Get.snackbar(
        'Erreur',
        'Veuillez saisir un lieu pour l\'événement',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (organizerNameController.text.isEmpty) {
      Get.snackbar(
        'Erreur',
        'Veuillez saisir le nom de l\'organisateur',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Create new event
    isSubmitting.value = true;

    // Generate a unique ID
    String eventId = const Uuid().v4();

    // Prepare event data for Firestore
    Map<String, dynamic> eventData = {
      'title': titleController.text,
      'description': descriptionController.text,
      'date': eventDate.value, // Firestore will store this as a Timestamp
      'startTime': startTime.value,
      'endTime': endTime.value,
      'location': locationController.text,
      'category': eventCategory.value,
      'participants': 0,
      'organizerId': 'current_user_id', // In a real app, get this from auth
      'organizerName': organizerNameController.text,
      'isUserParticipating': false,
      'createdAt': FieldValue.serverTimestamp(),
    };

    // Save to Firestore
    eventsCollection.doc(eventId).set(eventData).then((_) {
      isSubmitting.value = false;
      Get.back();

      Get.snackbar(
        'Succès',
        'Événement créé avec succès',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Reload events to show the new one
      loadEvents();
    }).catchError((error) {
      isSubmitting.value = false;
      print('Error creating event: $error');

      Get.snackbar(
        'Erreur',
        'Impossible de créer l\'événement',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    });
  }

  // Function to join/participate in an event
  Future<void> joinEvent(String eventId) async {
    try {
      // Get the current event document
      DocumentSnapshot eventDoc = await eventsCollection.doc(eventId).get();
      if (!eventDoc.exists) {
        throw Exception('Event not found');
      }

      Map<String, dynamic> eventData = eventDoc.data() as Map<String, dynamic>;
      int participants = eventData['participants'] ?? 0;

      // Update the participants count
      await eventsCollection.doc(eventId).update({
        'participants': participants + 1,
        // In a real app, you'd store user IDs in a 'participants' array to track who joined
      });

      // Update local state
      final index = events.indexWhere((event) => event.id == eventId);
      if (index != -1) {
        final updatedEvent = EventModel(
          id: events[index].id,
          title: events[index].title,
          description: events[index].description,
          date: events[index].date,
          startTime: events[index].startTime,
          endTime: events[index].endTime,
          location: events[index].location,
          category: events[index].category,
          participants: events[index].participants + 1,
          organizerId: events[index].organizerId,
          organizerName: events[index].organizerName,
          isUserParticipating: true,
        );

        events[index] = updatedEvent;
      }

      Get.snackbar(
        'Succès',
        'Vous avez rejoint l\'événement',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error joining event: $e');
      Get.snackbar(
        'Erreur',
        'Impossible de rejoindre l\'événement',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
