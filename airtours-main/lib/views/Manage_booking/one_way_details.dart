import 'package:AirTours/services/cloud/cloud_booking.dart';
import 'package:AirTours/services/cloud/cloud_flight.dart';
import 'package:AirTours/views/Global/paymentPage.dart';
import 'package:AirTours/views/Manage_booking/tickets_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/cloud/firestore_booking.dart';
import '../../services/cloud/firestore_flight.dart';
import '../Global/global_var.dart';
import '../Global/ticket.dart';

class OneWayDetails extends StatefulWidget {
  final CloudBooking booking;
  final CloudFlight depFlight;

  const OneWayDetails({
    super.key,
    required this.booking,
    required this.depFlight,
  });

  @override
  State<OneWayDetails> createState() => _OneWayDetailsState();
}

class _OneWayDetailsState extends State<OneWayDetails> {
  late final BookingFirestore _bookingService;
  late final CloudFlight departFlight;
  late final CloudBooking currentBooking;
  late final FlightFirestore _flightsService;
  late String bookingType;
  List<Ticket> tickets = [];

  @override
  void initState() {
    super.initState();
    _bookingService = BookingFirestore();
    departFlight = widget.depFlight;
    currentBooking = widget.booking;
    _flightsService = FlightFirestore();
    bookingType = currentBooking.bookingClass;
  }

  String date1(Timestamp date) {
    DateTime departureDate = date.toDate();
    DateFormat formatter = DateFormat('MM dd yyyy');
    String formattedDate = formatter.format(departureDate);
    List<String> parts = formattedDate.split(' ');
    int month = int.parse(parts[0]);
    String monthName = monthNames[month];
    String day = parts[1];
    String year = parts[2];
    return '$monthName $day $year';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Details'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TicketsView(
                          booking: widget.booking, flight: widget.depFlight),
                    ));
              },
              child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      boxShadow: const [
                        BoxShadow(blurRadius: 2, offset: Offset(0, 0))
                      ],
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white),
                  child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Destination Flight",
                                style: TextStyle(fontSize: 22),
                              ),
                              Text(
                                date1(departFlight.depDate),
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            height: 1.0,
                            color: Colors.black,
                            width: double.infinity,
                            //child: SizedBox.expand(),
                          ),
                          Column(children: [
                            Row(
                              children: [
                                Text(
                                  widget.depFlight.fromCity,
                                  style: const TextStyle(fontSize: 19),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Container(
                                  height: 20,
                                  child: Image.asset('images/flight-Icon.png'),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  widget.depFlight.toCity,
                                  style: const TextStyle(fontSize: 19),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          _flightsService
                                              .formatTime(departFlight.depTime),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        const SizedBox(
                                          width: 20,
                                          child: Text("-"),
                                        ),
                                        Text(
                                          _flightsService
                                              .formatTime(departFlight.arrTime),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                            "Price: ${widget.booking.bookingPrice}")
                                      ],
                                    )
                                  ],
                                )
                              ],
                            )
                          ]),
                        ],
                      )))),
          const SizedBox(height: 16.0),
          Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Spacer(),
                  Visibility(
                    visible: bookingType != 'business',
                    child: ElevatedButton(
                      onPressed: () async {
                        bool? nextPage = await Navigator.push(
                          context,
                          MaterialPageRoute<bool>(
                              builder: (context) => Payment(
                                  paymentFor: 'upgrade',
                                  id1: 'none',
                                  id2: 'none',
                                  flightClass: 'none',
                                  tickets: tickets)),
                        );
                        if (nextPage == true) {
                          bool result = await _bookingService.upgradeOneWay(
                            bookingId: currentBooking.documentId,
                            departureFlightId: departFlight.documentId,
                            numOfPas: currentBooking.numOfSeats,
                          );
                          if (result) {
                            setState(() {
                              bookingType = 'business';
                            });
                          }
                        } else {
                          print('not sucessfull');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                          vertical: 16.0,
                          horizontal: 24.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: const Text(
                        'Upgrade Booking',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  ElevatedButton(
                    onPressed: () async {
                      bool result = await _bookingService.deleteBooking(
                          bookingId: currentBooking.documentId,
                          flightId1: departFlight.documentId,
                          flightId2: 'none',
                          flightClass: currentBooking.bookingClass,
                          numOfPas: currentBooking.numOfSeats);
                      print(result);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16.0,
                        horizontal: 24.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Text(
                      'Cancel Booking',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
