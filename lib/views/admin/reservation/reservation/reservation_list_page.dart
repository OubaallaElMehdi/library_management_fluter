import 'package:flutter/material.dart';
import 'package:library_management/models/reservationStatuses.dart';
import 'package:library_management/models/reservation.dart';
import 'package:library_management/models/reservationitem.dart';
import 'package:library_management/services/reservation_admin_service.dart';

class ReservationAdminPage extends StatefulWidget {
  const ReservationAdminPage({super.key});

  @override
  State<ReservationAdminPage> createState() => _ReservationAdminPageState();
}

class _ReservationAdminPageState extends State<ReservationAdminPage> {
  final ReservationAdminService reservationService = ReservationAdminService();

  late Future<List<Reservationitem>> reservationsFuture;
  int currentPage = 0;
  final int maxResults = 5;

  @override
  void initState() {
    super.initState();
    reservationsFuture = fetchReservations();
  }

  Future<List<Reservationitem>> fetchReservations() async {
    final response = await reservationService.fetchPaginatedReservations(
      page: currentPage,
      maxResults: maxResults,
      sortOrder: 'ASC',
      sortField: 'requestDate',
    );

    final List<dynamic> data = response['list'];
    return data.map((json) => Reservationitem.fromJson(json)).toList();
  }

  Future<void> updateReservationState(
      Reservationitem reservation, Map<String, dynamic> newState) async {
    final updatedReservation = {
      "id": reservation.id, // Include the reservation ID
      "booklabel": reservation.booklabel,
      "requestDate": reservation.requestDate,
      "theoreticalReturnDate": reservation.theoreticalReturnDate,
      "reservationState": newState,
    };

    try {
      await reservationService.updateReservation(updatedReservation);
      setState(() {
        reservationsFuture = fetchReservations();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reservation state updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating reservation: $e')),
      );
    }
  }

  Color getColorFromStyle(String style) {
    switch (style) {
      case "success":
        return Colors.green;
      case "primary":
        return Colors.blue;
      case "danger":
        return Colors.red;
      case "warning":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void loadNextPage() {
    setState(() {
      currentPage++;
      reservationsFuture = fetchReservations();
    });
  }

  void loadPreviousPage() {
    if (currentPage > 0) {
      setState(() {
        currentPage--;
        reservationsFuture = fetchReservations();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Reservations"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Reservationitem>>(
              future: reservationsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No reservations found.'),
                  );
                }

                final reservations = snapshot.data!;
                return ListView.builder(
                  itemCount: reservations.length,
                  itemBuilder: (context, index) {
                    final reservation = reservations[index];
                    final currentStatus = reservation.reservationState;

                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      color: Colors.grey[50],
                      child: ListTile(
                        title: Text('Reservation Code: ${reservation.code}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Book: ${reservation.booklabel}'),
                            Text(
                              'Client: ${reservation.client["username"] ?? "N/A"}',
                              style: const TextStyle(color: Colors.black87),
                            ),
                          ],
                        ),
                        trailing: DropdownButton<Map<String, dynamic>>(
                          value: reservationStatuses.firstWhere(
                            (status) => status["code"] == currentStatus?.code,
                            orElse: () => reservationStatuses[0],
                          ),
                          items: reservationStatuses.map((status) {
                            return DropdownMenuItem(
                              value: status,
                              child: Text(
                                status["label"] as String, // Explicit cast
                                style: TextStyle(
                                  color: getColorFromStyle(
                                      status["style"] as String), // Cast style
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (newState) {
                            if (newState != null) {
                              updateReservationState(reservation, newState);
                            }
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: currentPage > 0 ? loadPreviousPage : null,
              ),
              Text('Page ${currentPage + 1}'),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: loadNextPage,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
