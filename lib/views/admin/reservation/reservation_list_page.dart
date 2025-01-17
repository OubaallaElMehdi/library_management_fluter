import 'package:flutter/material.dart';
import 'package:library_management/services/resvationadmin_service.dart';
import 'package:library_management/views/admin/reservation/reservation_detail_page.dart';
import 'package:library_management/widgets/custom_drawer.dart'; // Import the CustomDrawer widget

class AdminReservationPage extends StatefulWidget {
  const AdminReservationPage({super.key});

  @override
  State<AdminReservationPage> createState() => _AdminReservationPageState();
}

class _AdminReservationPageState extends State<AdminReservationPage> {
  final AdminReservationService reservationService = AdminReservationService();
  late Future<Map<String, dynamic>> reservationsFuture;
  int currentPage = 0;
  final int maxResults = 5;

  @override
  void initState() {
    super.initState();
    reservationsFuture = fetchReservations();
  }

  Future<Map<String, dynamic>> fetchReservations() {
    return reservationService.fetchPaginatedReservations(
      page: currentPage,
      maxResults: maxResults,
    );
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
        title: const Text(
          'Reservations',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(
              Icons.menu,
              color: Colors.blue,
            ),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      drawer: const CustomDrawer(role: 'Admin'), // Add the drawer here
      body: FutureBuilder<Map<String, dynamic>>(
        future: reservationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final reservations = snapshot.data?['list'] ?? [];

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: reservations.length,
                  itemBuilder: (context, index) {
                    final reservation = reservations[index];
                    final id = reservation['id'];
                    final code = reservation['code'] ?? '';

                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text('Reservation ID: $id'),
                        subtitle: Text('Code: $code'),
                        trailing: ElevatedButton(
                          onPressed: () {
                            // Navigate to detail page
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReservationDetailPage(
                                  reservation: {
                                    "id": id,
                                    "code": code,
                                  },
                                ),
                              ),
                            );
                          },
                          child: const Text('Affect Copy'),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: (currentPage > 0) ? loadPreviousPage : null,
                  ),
                  Text('Page ${currentPage + 1}'),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: loadNextPage,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
