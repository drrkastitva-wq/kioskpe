import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../core/constants/api_constants.dart';

// ─── Data models ──────────────────────────────────────────────────────────────

class _Holiday {
  final String id;
  final DateTime date;
  final String title;
  final String description;
  final String type; // national | court_vacation | court_specific | gazetted | restricted
  final List<String> courts;

  const _Holiday({
    required this.id,
    required this.date,
    required this.title,
    required this.description,
    required this.type,
    required this.courts,
  });

  factory _Holiday.fromJson(Map<String, dynamic> j) {
    return _Holiday(
      id: j['id']?.toString() ?? '',
      date: DateTime.tryParse(j['date']?.toString() ?? '') ?? DateTime.now(),
      title: j['title']?.toString() ?? '',
      description: j['description']?.toString() ?? '',
      type: j['type']?.toString() ?? 'national',
      courts: (j['courts'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Color get color {
    switch (type) {
      case 'national':
        return const Color(0xFFC62828); // red
      case 'court_vacation':
        return const Color(0xFFE65100); // orange
      case 'court_specific':
        return const Color(0xFF6A1B9A); // purple
      case 'gazetted':
        return const Color(0xFF1565C0); // blue
      case 'restricted':
        return const Color(0xFF37474F); // grey
      default:
        return const Color(0xFFC62828);
    }
  }

  String get typeLabel {
    switch (type) {
      case 'national':
        return 'National Holiday';
      case 'court_vacation':
        return 'Court Vacation';
      case 'court_specific':
        return 'Court-Specific Holiday';
      case 'gazetted':
        return 'Gazetted Holiday';
      case 'restricted':
        return 'Restricted Holiday';
      default:
        return 'Holiday';
    }
  }
}

class _Court {
  final String id;
  final String label;
  final String city;
  final String state;
  final String website;
  final String calendarUrl;
  final String description;

  const _Court({
    required this.id,
    required this.label,
    required this.city,
    this.state = '',
    this.website = '',
    this.calendarUrl = '',
    this.description = '',
  });

  factory _Court.fromJson(Map<String, dynamic> j) => _Court(
        id: j['id']?.toString() ?? '',
        label: j['label']?.toString() ?? '',
        city: j['city']?.toString() ?? '',
        state: j['state']?.toString() ?? '',
        website: j['website']?.toString() ?? '',
        calendarUrl: j['calendarUrl']?.toString() ?? '',
        description: j['description']?.toString() ?? '',
      );

  String get effectiveWebsite => calendarUrl.isNotEmpty ? calendarUrl : website;
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class CourtCalendarScreen extends StatefulWidget {
  const CourtCalendarScreen({super.key});

  @override
  State<CourtCalendarScreen> createState() => _CourtCalendarScreenState();
}

class _CourtCalendarScreenState extends State<CourtCalendarScreen> {
  // Calendar state
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Data
  Map<DateTime, List<_Holiday>> _holidayMap = {};
  List<_Court> _courts = [
    const _Court(id: 'all', label: 'All Courts (National)', city: 'India', state: 'India', website: 'https://ecourts.gov.in'),
  ];
  String _selectedCourtId = 'all';
  bool _loadingCourts = true;
  bool _loadingHolidays = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _loadCourts();
    _loadHolidays();
  }

  Future<void> _loadCourts() async {
    try {
      final data = await ApiService.get(ApiConstants.calendarCourts);
      final list = (data['courts'] ?? data) as List;
      // Filter out any court with id 'all' from API to avoid duplicate DropdownMenuItem values
      final apiCourts = list
          .map((c) => _Court.fromJson(c as Map<String, dynamic>))
          .where((c) => c.id != 'all')
          .toList();
      setState(() {
        _courts = [
          const _Court(id: 'all', label: 'All Courts (National)', city: 'India', state: 'India', website: 'https://ecourts.gov.in'),
          ...apiCourts,
        ];
        // Ensure selected value still exists
        if (!_courts.any((c) => c.id == _selectedCourtId)) {
          _selectedCourtId = 'all';
        }
        _loadingCourts = false;
      });
    } catch (_) {
      setState(() {
        _courts = [const _Court(id: 'all', label: 'All Courts (National)', city: 'India')];
        _selectedCourtId = 'all';
        _loadingCourts = false;
      });
    }
  }

  Future<void> _loadHolidays() async {
    setState(() => _loadingHolidays = true);
    try {
      final year = _focusedDay.year;
      final url = '${ApiConstants.holidays}?year=$year&court=$_selectedCourtId';
      final data = await ApiService.get(url);
      final list = (data['holidays'] ?? data) as List;
      final Map<DateTime, List<_Holiday>> map = {};
      for (final h in list) {
        final holiday = _Holiday.fromJson(h as Map<String, dynamic>);
        final key = DateTime(holiday.date.year, holiday.date.month, holiday.date.day);
        map[key] = [...(map[key] ?? []), holiday];
      }
      setState(() {
        _holidayMap = map;
        _loadingHolidays = false;
      });
    } catch (_) {
      setState(() => _loadingHolidays = false);
    }
  }

  List<_Holiday> _holidaysOn(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return _holidayMap[key] ?? [];
  }

  bool _isWeekend(DateTime day) {
    return day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedDay ?? _focusedDay;
    final dayHolidays = _holidaysOn(selected);
    final isWeekend = _isWeekend(selected);
    final isToday = isSameDay(selected, DateTime.now());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Court Calendar'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadHolidays,
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Court selector ─────────────────────────────────────────────
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: _loadingCourts
                ? const SizedBox(
                    height: 44,
                    child: Center(child: LinearProgressIndicator(color: Colors.white70, backgroundColor: Colors.white24)),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white30),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _courts.any((c) => c.id == _selectedCourtId)
                                ? _selectedCourtId
                                : _courts.first.id,
                            dropdownColor: const Color(0xFF1A237E),
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            icon: const Icon(Icons.expand_more, color: Colors.white),
                            isExpanded: true,
                            items: _courts.map((c) => DropdownMenuItem(
                              value: c.id,
                              child: Text('${c.label}  •  ${c.city}',
                                  style: const TextStyle(color: Colors.white, fontSize: 13)),
                            )).toList(),
                            onChanged: (val) {
                              if (val != null && val != _selectedCourtId) {
                                setState(() => _selectedCourtId = val);
                                _loadHolidays();
                              }
                            },
                          ),
                        ),
                      ),
                      // Court info row (state + website button)
                      Builder(builder: (context) {
                        final court = _courts.firstWhere(
                          (c) => c.id == _selectedCourtId,
                          orElse: () => const _Court(id: '', label: '', city: ''),
                        );
                        final hasWebsite = court.effectiveWebsite.isNotEmpty;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              if (court.state.isNotEmpty) ...[  
                                const Icon(Icons.location_on, color: Colors.white70, size: 13),
                                const SizedBox(width: 3),
                                Text(
                                  court.state,
                                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                                ),
                                const SizedBox(width: 12),
                              ],
                              if (hasWebsite)
                                InkWell(
                                  onTap: () async {
                                    final uri = Uri.parse(court.effectiveWebsite);
                                    if (await canLaunchUrl(uri)) {
                                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.white38),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.open_in_browser, color: Colors.white, size: 13),
                                        SizedBox(width: 5),
                                        Text('Official Calendar',
                                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
          ),

          // ── Calendar ───────────────────────────────────────────────────
          _loadingHolidays
              ? const LinearProgressIndicator()
              : const SizedBox(height: 2),
          TableCalendar<_Holiday>(
            firstDay: DateTime(2024),
            lastDay: DateTime(2027),
            focusedDay: _focusedDay,
            selectedDayPredicate: (d) => isSameDay(d, _selectedDay),
            onDaySelected: (s, f) => setState(() { _selectedDay = s; _focusedDay = f; }),
            onPageChanged: (f) {
              _focusedDay = f;
              _loadHolidays();
            },
            eventLoader: _holidaysOn,
            calendarBuilders: CalendarBuilders(
              // Colour-code day numbers for weekends / holidays
              defaultBuilder: (ctx, day, focusedDay) {
                final isWknd = _isWeekend(day);
                final hasHol = _holidaysOn(day).isNotEmpty;
                if (!isWknd && !hasHol) return null;
                return Center(
                  child: Text(
                    '${day.day}',
                    style: TextStyle(
                      color: hasHol
                          ? _holidaysOn(day).first.color
                          : Colors.blueGrey,
                      fontWeight: hasHol ? FontWeight.w700 : FontWeight.normal,
                    ),
                  ),
                );
              },
              // Custom marker dots
              markerBuilder: (ctx, day, events) {
                if (events.isEmpty) return const SizedBox.shrink();
                return Positioned(
                  bottom: 4,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: events.take(3).map((e) => Container(
                      width: 5, height: 5,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: e.color,
                      ),
                    )).toList(),
                  ),
                );
              },
            ),
            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.18),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blue, width: 1.5),
              ),
              weekendTextStyle: const TextStyle(color: Colors.blueGrey),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),

          const Divider(height: 1),

          // ── Legend ─────────────────────────────────────────────────────
          _LegendRow(),

          const Divider(height: 1),

          // ── Selected day detail ────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          DateFormat('EEEE, d MMMM yyyy').format(selected),
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      if (isToday) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text('Today',
                              style: TextStyle(color: Colors.blue, fontSize: 11, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Weekend indicator
                  if (isWeekend)
                    _StatusChip(
                      icon: Icons.weekend,
                      label: 'Weekend — Courts are closed on ${selected.weekday == DateTime.saturday ? "Saturday" : "Sunday"}',
                      color: Colors.blueGrey,
                    ),

                  // Holiday cards
                  if (dayHolidays.isNotEmpty) ...[
                    if (isWeekend) const SizedBox(height: 8),
                    ...dayHolidays.map((h) => _HolidayCard(holiday: h)),

                    // Vacation bench notice
                    if (dayHolidays.any((h) => h.type == 'court_vacation'))
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFFF8F00).withOpacity(0.4)),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info_outline, color: Color(0xFFE65100), size: 18),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Vacation Bench: Urgent matters may still be heard by the Vacation Bench during court vacation periods. Contact court registry for details.',
                                style: TextStyle(fontSize: 12, color: Color(0xFF5D4037)),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ] else if (!isWeekend) ...[
                    _StatusChip(
                      icon: Icons.event_available,
                      label: 'Working day — Courts are in session',
                      color: const Color(0xFF2E7D32),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Legend row ───────────────────────────────────────────────────────────────

class _LegendRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const items = [
      (color: Color(0xFFC62828), label: 'National'),
      (color: Color(0xFFE65100), label: 'Vacation'),
      (color: Color(0xFF6A1B9A), label: 'Court-specific'),
      (color: Color(0xFF1565C0), label: 'Gazetted'),
      (color: Colors.blueGrey, label: 'Weekend'),
    ];
    return Container(
      color: Colors.grey.shade50,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: items.map((item) => Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Row(children: [
              CircleAvatar(backgroundColor: item.color, radius: 5),
              const SizedBox(width: 5),
              Text(item.label, style: const TextStyle(fontSize: 11, color: Colors.black54)),
            ]),
          )).toList(),
        ),
      ),
    );
  }
}

// ─── Holiday card ─────────────────────────────────────────────────────────────

class _HolidayCard extends StatelessWidget {
  final _Holiday holiday;
  const _HolidayCard({required this.holiday});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: holiday.color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: holiday.color.withOpacity(0.25)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: holiday.color.withOpacity(0.15),
          child: Icon(Icons.event_busy, color: holiday.color, size: 18),
        ),
        title: Text(holiday.title,
            style: TextStyle(fontWeight: FontWeight.w600, color: holiday.color, fontSize: 14)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (holiday.description.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(holiday.description, style: const TextStyle(fontSize: 12)),
            ],
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: holiday.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(holiday.typeLabel,
                  style: TextStyle(fontSize: 10, color: holiday.color, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}

// ─── Status chip ──────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _StatusChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Flexible(
            child: Text(label,
                style: TextStyle(color: color, fontWeight: FontWeight.w500, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
