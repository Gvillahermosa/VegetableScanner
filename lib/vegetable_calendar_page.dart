import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'notifications_page.dart';
import 'profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';

class VegetableCalendarPage extends StatefulWidget {
  const VegetableCalendarPage({super.key});

  @override
  State<VegetableCalendarPage> createState() => _VegetableCalendarPageState();
}

class _VegetableCalendarPageState extends State<VegetableCalendarPage> {
  late DateTime _selectedMonth;
  late int _selectedDay;

  // Sample data for soon-to-expire vegetables - can be empty for testing
  List<Map<String, dynamic>> _expiringVegetables = [
    {
      'name': 'Tomato',
      'startDate': '04/03/25',
      'expiryDate': '04/20/25',
      'icon': Icons.circle,
      'color': Colors.red,
    },
    {
      'name': 'Tomato',
      'startDate': '04/03/25',
      'expiryDate': '04/20/25',
      'icon': Icons.circle,
      'color': Colors.red,
    },
    {
      'name': 'Tomato',
      'startDate': '04/03/25',
      'expiryDate': '04/20/25',
      'icon': Icons.circle,
      'color': Colors.red,
    },
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month, 1);
    _selectedDay = now.day; // Set selected day to current day

    // Uncomment to test empty state
    _expiringVegetables = [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Vegetable Calendar',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Calendar Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Month navigation
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left),
                            onPressed: () {
                              setState(() {
                                _selectedMonth = DateTime(
                                  _selectedMonth.year,
                                  _selectedMonth.month - 1,
                                  1,
                                );
                                // Reset selected day when month changes
                                if (_selectedMonth.month ==
                                        DateTime.now().month &&
                                    _selectedMonth.year ==
                                        DateTime.now().year) {
                                  _selectedDay = DateTime.now().day;
                                } else {
                                  _selectedDay = 1;
                                }
                              });
                            },
                          ),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text:
                                      DateFormat('MMMM').format(_selectedMonth),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                WidgetSpan(
                                  child: Container(
                                    width: 4,
                                    height: 4,
                                    margin: const EdgeInsets.only(
                                        left: 4, bottom: 10),
                                    decoration: const BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                                TextSpan(
                                  text:
                                      ' ${DateFormat('yyyy').format(_selectedMonth)}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                WidgetSpan(
                                  child: Container(
                                    width: 4,
                                    height: 4,
                                    margin: const EdgeInsets.only(
                                        left: 4, bottom: 10),
                                    decoration: const BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right),
                            onPressed: () {
                              setState(() {
                                _selectedMonth = DateTime(
                                  _selectedMonth.year,
                                  _selectedMonth.month + 1,
                                  1,
                                );
                                // Reset selected day when month changes
                                if (_selectedMonth.month ==
                                        DateTime.now().month &&
                                    _selectedMonth.year ==
                                        DateTime.now().year) {
                                  _selectedDay = DateTime.now().day;
                                } else {
                                  _selectedDay = 1;
                                }
                              });
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Weekday headers
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: const [
                          _WeekdayLabel('Mo'),
                          _WeekdayLabel('Tu'),
                          _WeekdayLabel('We'),
                          _WeekdayLabel('Th'),
                          _WeekdayLabel('Fr'),
                          _WeekdayLabel('Sa'),
                          _WeekdayLabel('Su'),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Calendar days
                      _buildCalendarGrid(),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Soon-to-Expire Section
              const Padding(
                padding: EdgeInsets.only(left: 16, bottom: 8),
                child: Text(
                  'Soon-to-Expire Vegetables',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              // Empty state or vegetable list
              _expiringVegetables.isEmpty
                  ? _buildEmptyState()
                  : _buildVegetableList(),

              // Add padding at the bottom to ensure the last item is fully visible
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildEmptyState() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 48,
                color: Colors.green[300],
              ),
              const SizedBox(height: 16),
              const Text(
                'No vegetables nearing their expiration date',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'All your vegetables are fresh!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVegetableList() {
    return Column(
      children: _expiringVegetables.map((vegetable) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(
                  vegetable['icon'],
                  color: vegetable['color'],
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vegetable['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${vegetable['startDate']} - ${vegetable['expiryDate']}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendarGrid() {
    // Get the first day of the month
    final firstDayOfMonth =
        DateTime(_selectedMonth.year, _selectedMonth.month, 1);

    // Calculate what day of the week the first day is (0 = Monday in our display)
    int firstWeekdayOfMonth = firstDayOfMonth.weekday - 1;
    if (firstWeekdayOfMonth < 0) firstWeekdayOfMonth = 6; // Sunday adjustment

    // Get the number of days in the month
    final daysInMonth =
        DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;

    // Previous month's overflow days
    final daysInPreviousMonth =
        DateTime(_selectedMonth.year, _selectedMonth.month, 0).day;

    // Calculate how many rows we need
    int totalSlots = (firstWeekdayOfMonth + daysInMonth);
    int rowCount = (totalSlots / 7).ceil();

    List<Widget> rows = [];
    int dayCounter = 1;
    int nextMonthCounter = 1;

    for (int i = 0; i < rowCount; i++) {
      List<Widget> rowChildren = [];

      for (int j = 0; j < 7; j++) {
        int displayNum;
        bool isCurrentMonth;

        // Slots before the 1st of the month
        if (i == 0 && j < firstWeekdayOfMonth) {
          displayNum = daysInPreviousMonth - (firstWeekdayOfMonth - j - 1);
          isCurrentMonth = false;
        }
        // Slots after the last day of the month
        else if (dayCounter > daysInMonth) {
          displayNum = nextMonthCounter++;
          isCurrentMonth = false;
        }
        // Current month days
        else {
          displayNum = dayCounter++;
          isCurrentMonth = true;
        }

        bool isSelected = isCurrentMonth && displayNum == _selectedDay;

        // Check if this day is today
        final now = DateTime.now();
        bool isToday = isCurrentMonth &&
            displayNum == now.day &&
            _selectedMonth.month == now.month &&
            _selectedMonth.year == now.year;

        rowChildren.add(
          _CalendarDay(
            day: displayNum,
            isCurrentMonth: isCurrentMonth,
            isSelected: isSelected,
            isToday: isToday,
            onTap: isCurrentMonth
                ? () {
                    setState(() {
                      _selectedDay = displayNum;
                    });
                  }
                : null,
          ),
        );
      }

      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: rowChildren,
        ),
      );

      // Add spacing between rows
      if (i < rowCount - 1) {
        rows.add(const SizedBox(height: 16));
      }
    }

    return Column(children: rows);
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavBarItem(
            icon: Icons.notifications_outlined,
            isSelected: false,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const NotificationsPage()),
            ),
          ),
          _buildNavBarItem(
            icon: Icons.home,
            isSelected: false,
            onTap: () => Navigator.popUntil(context, (route) => route.isFirst),
          ),
          _buildCircularProfileButton(context),
        ],
      ),
    );
  }

  Widget _buildNavBarItem({
    required IconData icon,
    required bool isSelected,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color:
              isSelected ? Colors.green.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Icon(
          icon,
          color: isSelected ? Colors.green : Colors.grey,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildCircularProfileButton(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String? photoUrl = user?.photoURL;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                user != null ? const ProfilePage() : const LoginPage(),
          ),
        );
      },
      child: Container(
        width: 48,
        height: 48,
        padding: const EdgeInsets.all(2), // space for border
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.green,
            width: 2.5,
          ),
        ),
        child: CircleAvatar(
          backgroundColor: Colors.grey[200],
          backgroundImage:
              (user != null && photoUrl != null && photoUrl.isNotEmpty)
                  ? NetworkImage(photoUrl)
                  : null,
          child: (user == null || photoUrl == null || photoUrl.isEmpty)
              ? const Icon(Icons.person, color: Colors.green)
              : null,
        ),
      ),
    );
  }
}

class _WeekdayLabel extends StatelessWidget {
  final String day;

  const _WeekdayLabel(this.day);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30,
      child: Text(
        day,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.grey[700],
        ),
      ),
    );
  }
}

class _CalendarDay extends StatelessWidget {
  final int day;
  final bool isCurrentMonth;
  final bool isSelected;
  final bool isToday;
  final VoidCallback? onTap;

  const _CalendarDay({
    required this.day,
    required this.isCurrentMonth,
    required this.isSelected,
    this.isToday = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.green
              : isToday
                  ? Colors.green.withOpacity(0.2)
                  : Colors.transparent,
          shape: BoxShape.circle,
          border: isToday && !isSelected
              ? Border.all(color: Colors.green, width: 1)
              : null,
        ),
        child: Center(
          child: Text(
            day.toString(),
            style: TextStyle(
              fontSize: 14,
              fontWeight:
                  isSelected || isToday ? FontWeight.bold : FontWeight.normal,
              color: !isCurrentMonth
                  ? Colors.grey[400]
                  : isSelected
                      ? Colors.white
                      : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
