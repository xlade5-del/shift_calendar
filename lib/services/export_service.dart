import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/event_model.dart';

/// Service for exporting calendar data in various formats
class ExportService {
  /// Generate a text summary of events for a given month
  ///
  /// Returns a formatted string with all events grouped by date
  String generateTextSummary(
    List<EventModel> events,
    DateTime monthStart,
    String userName,
  ) {
    final buffer = StringBuffer();
    final monthName = DateFormat('MMMM yyyy').format(monthStart);

    // Header
    buffer.writeln('$userName\'s $monthName Schedule');
    buffer.writeln();

    // Get all days in the month
    final monthEnd = DateTime(monthStart.year, monthStart.month + 1, 0);
    final daysInMonth = monthEnd.day;

    // Group events by date
    final eventsByDate = <String, List<EventModel>>{};
    for (final event in events) {
      final dateKey = DateFormat('yyyy-MM-dd').format(event.startTime);
      eventsByDate.putIfAbsent(dateKey, () => []).add(event);
    }

    // Sort events within each day
    eventsByDate.forEach((key, value) {
      value.sort((a, b) => a.startTime.compareTo(b.startTime));
    });

    // Iterate through each day of the month
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(monthStart.year, monthStart.month, day);
      final dateKey = DateFormat('yyyy-MM-dd').format(date);
      final dayName = DateFormat('EEEE, MMMM d').format(date);

      buffer.writeln(dayName);

      final dayEvents = eventsByDate[dateKey];
      if (dayEvents == null || dayEvents.isEmpty) {
        buffer.writeln('No shifts scheduled');
      } else {
        for (final event in dayEvents) {
          final startTime = DateFormat('h:mm a').format(event.startTime);
          final endTime = DateFormat('h:mm a').format(event.endTime);
          buffer.writeln('• ${event.title}: $startTime - $endTime');
        }
      }

      buffer.writeln();
    }

    // Summary statistics
    buffer.writeln('---');
    final totalEvents = events.length;
    final totalHours = events.fold<double>(
      0.0,
      (sum, event) =>
          sum + event.endTime.difference(event.startTime).inMinutes / 60.0,
    );

    buffer.writeln('Total: $totalEvents shifts this month');
    buffer.writeln('Work hours: ${totalHours.toStringAsFixed(1)} hours');
    buffer.writeln();
    buffer.writeln('Shared from VelloShift');

    return buffer.toString();
  }

  /// Generate an iCal (.ics) file from events
  ///
  /// Returns the file path of the generated .ics file
  Future<String> generateIcalFile(
    List<EventModel> events,
    String userId, {
    String calendarName = 'VelloShift Calendar',
  }) async {
    final buffer = StringBuffer();

    // iCal header
    buffer.writeln('BEGIN:VCALENDAR');
    buffer.writeln('VERSION:2.0');
    buffer.writeln('PRODID:-//VelloShift//EN');
    buffer.writeln('CALSCALE:GREGORIAN');
    buffer.writeln('METHOD:PUBLISH');
    buffer.writeln('X-WR-CALNAME:$calendarName');
    buffer.writeln('X-WR-TIMEZONE:UTC');

    // Add each event
    for (final event in events) {
      buffer.writeln('BEGIN:VEVENT');
      buffer.writeln('UID:${event.eventId}@velloshift.com');

      // Format dates in UTC (YYYYMMDDTHHMMSSZ)
      final dtStart = _formatIcalDateTime(event.startTime);
      final dtEnd = _formatIcalDateTime(event.endTime);

      buffer.writeln('DTSTART:$dtStart');
      buffer.writeln('DTEND:$dtEnd');
      buffer.writeln('SUMMARY:${_escapeIcalText(event.title)}');

      if (event.notes != null && event.notes!.isNotEmpty) {
        buffer.writeln('DESCRIPTION:${_escapeIcalText(event.notes!)}');
      }

      // Add color as category (some calendar apps support this)
      buffer.writeln('CATEGORIES:${event.color}');

      // Timestamps
      final now = _formatIcalDateTime(DateTime.now());
      buffer.writeln('DTSTAMP:$now');
      buffer.writeln('CREATED:${_formatIcalDateTime(event.createdAt)}');
      buffer.writeln('LAST-MODIFIED:${_formatIcalDateTime(event.updatedAt)}');

      buffer.writeln('END:VEVENT');
    }

    buffer.writeln('END:VCALENDAR');

    // Save to temp file
    final directory = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filePath = '${directory.path}/velloshift_export_$timestamp.ics';

    final file = File(filePath);
    await file.writeAsString(buffer.toString());

    return filePath;
  }

  /// Generate a PDF calendar from events
  ///
  /// Returns the file path of the generated PDF
  Future<String> generatePdfFile(
    List<EventModel> events,
    DateTime startDate,
    DateTime endDate, {
    required bool isYearView,
  }) async {
    final pdf = pw.Document();

    if (isYearView) {
      // Year view: 12 mini calendars
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4.landscape,
          build: (context) => _buildYearView(events, startDate.year),
        ),
      );
    } else {
      // Month view: single month calendar
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) => _buildMonthView(events, startDate),
        ),
      );
    }

    // Save to temp file
    final directory = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filePath = '${directory.path}/velloshift_calendar_$timestamp.pdf';

    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    return filePath;
  }

  /// Build month view PDF layout
  pw.Widget _buildMonthView(List<EventModel> events, DateTime monthStart) {
    final monthName = DateFormat('MMMM yyyy').format(monthStart);
    final monthEnd = DateTime(monthStart.year, monthStart.month + 1, 0);
    final daysInMonth = monthEnd.day;
    final firstWeekday = monthStart.weekday; // 1 = Monday

    // Group events by date
    final eventsByDate = <String, List<EventModel>>{};
    for (final event in events) {
      final dateKey = DateFormat('yyyy-MM-dd').format(event.startTime);
      eventsByDate.putIfAbsent(dateKey, () => []).add(event);
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Header
        pw.Container(
          padding: const pw.EdgeInsets.all(20),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                monthName,
                style: pw.TextStyle(
                  fontSize: 32,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'VelloShift Calendar',
                style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
              ),
            ],
          ),
        ),

        // Calendar grid
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 20),
            child: pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              children: [
                // Day headers
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                      .map((day) => pw.Container(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Center(
                              child: pw.Text(
                                day,
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                              ),
                            ),
                          ))
                      .toList(),
                ),

                // Calendar days
                ..._buildCalendarRows(daysInMonth, firstWeekday, monthStart, eventsByDate),
              ],
            ),
          ),
        ),

        // Footer
        pw.Container(
          padding: const pw.EdgeInsets.all(20),
          child: pw.Text(
            'Generated by VelloShift',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
          ),
        ),
      ],
    );
  }

  /// Build calendar rows for PDF month view
  List<pw.TableRow> _buildCalendarRows(
    int daysInMonth,
    int firstWeekday,
    DateTime monthStart,
    Map<String, List<EventModel>> eventsByDate,
  ) {
    final rows = <pw.TableRow>[];
    int day = 1;
    int currentWeekday = firstWeekday;

    // First row (may have leading empty cells)
    final firstRowCells = <pw.Widget>[];
    for (int i = 1; i < firstWeekday; i++) {
      firstRowCells.add(pw.Container()); // Empty cell
    }

    while (day <= daysInMonth) {
      if (currentWeekday > 7) {
        rows.add(pw.TableRow(children: List.from(firstRowCells)));
        firstRowCells.clear();
        currentWeekday = 1;
      }

      final date = DateTime(monthStart.year, monthStart.month, day);
      final dateKey = DateFormat('yyyy-MM-dd').format(date);
      final dayEvents = eventsByDate[dateKey] ?? [];

      firstRowCells.add(_buildDayCell(day, dayEvents));

      day++;
      currentWeekday++;
    }

    // Fill remaining cells in last row
    while (firstRowCells.length < 7) {
      firstRowCells.add(pw.Container());
    }
    rows.add(pw.TableRow(children: firstRowCells));

    return rows;
  }

  /// Build a single day cell for PDF month view
  pw.Widget _buildDayCell(int day, List<EventModel> events) {
    return pw.Container(
      height: 80,
      padding: const pw.EdgeInsets.all(4),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Day number
          pw.Text(
            day.toString(),
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 2),

          // Events (max 3)
          ...events.take(3).map((event) {
            final color = _hexToPdfColor(event.color);
            // Create semi-transparent color by blending with white
            final lightColor = PdfColor(
              color.red * 0.3 + 0.7,
              color.green * 0.3 + 0.7,
              color.blue * 0.3 + 0.7,
            );
            return pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 2),
              padding: const pw.EdgeInsets.all(2),
              decoration: pw.BoxDecoration(
                color: lightColor,
                borderRadius: pw.BorderRadius.circular(2),
              ),
              child: pw.Text(
                event.title,
                style: const pw.TextStyle(fontSize: 8),
                maxLines: 1,
                overflow: pw.TextOverflow.clip,
              ),
            );
          }),

          // "+X more" if overflow
          if (events.length > 3)
            pw.Text(
              '+${events.length - 3} more',
              style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
            ),
        ],
      ),
    );
  }

  /// Build year view PDF layout (12 mini calendars)
  pw.Widget _buildYearView(List<EventModel> events, int year) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Header
        pw.Container(
          padding: const pw.EdgeInsets.all(20),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                year.toString(),
                style: pw.TextStyle(fontSize: 40, fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                'VelloShift Calendar',
                style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
              ),
            ],
          ),
        ),

        // 12 month grid (3 rows × 4 columns)
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 20),
            child: pw.GridView(
              crossAxisCount: 4,
              children: List.generate(12, (index) {
                final month = index + 1;
                final monthStart = DateTime(year, month, 1);
                return _buildMiniMonthCalendar(events, monthStart);
              }),
            ),
          ),
        ),
      ],
    );
  }

  /// Build a mini month calendar for year view
  pw.Widget _buildMiniMonthCalendar(List<EventModel> events, DateTime monthStart) {
    final monthName = DateFormat('MMM').format(monthStart);
    final monthEnd = DateTime(monthStart.year, monthStart.month + 1, 0);
    final daysInMonth = monthEnd.day;
    final firstWeekday = monthStart.weekday;

    // Count events per day
    final eventCountByDate = <int, int>{};
    for (final event in events) {
      if (event.startTime.year == monthStart.year &&
          event.startTime.month == monthStart.month) {
        final day = event.startTime.day;
        eventCountByDate[day] = (eventCountByDate[day] ?? 0) + 1;
      }
    }

    return pw.Container(
      margin: const pw.EdgeInsets.all(8),
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            monthName,
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'M  T  W  T  F  S  S',
            style: const pw.TextStyle(fontSize: 6),
          ),
          pw.SizedBox(height: 2),
          // Mini grid
          ..._buildMiniMonthGrid(daysInMonth, firstWeekday, eventCountByDate),
        ],
      ),
    );
  }

  /// Build mini month grid for year view
  List<pw.Widget> _buildMiniMonthGrid(
    int daysInMonth,
    int firstWeekday,
    Map<int, int> eventCountByDate,
  ) {
    final rows = <pw.Widget>[];
    int day = 1;
    int currentWeekday = firstWeekday;
    var rowChildren = <pw.Widget>[];

    // Add leading empty cells
    for (int i = 1; i < firstWeekday; i++) {
      rowChildren.add(pw.SizedBox(width: 14));
    }

    while (day <= daysInMonth) {
      if (currentWeekday > 7) {
        rows.add(pw.Row(children: List.from(rowChildren)));
        rowChildren.clear();
        currentWeekday = 1;
      }

      final hasEvents = eventCountByDate.containsKey(day);
      rowChildren.add(
        pw.Container(
          width: 14,
          height: 14,
          margin: const pw.EdgeInsets.all(1),
          decoration: pw.BoxDecoration(
            color: hasEvents ? PdfColors.teal300 : null,
            shape: pw.BoxShape.circle,
            border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
          ),
          child: pw.Center(
            child: pw.Text(
              day.toString(),
              style: pw.TextStyle(
                fontSize: 6,
                color: hasEvents ? PdfColors.white : PdfColors.black,
              ),
            ),
          ),
        ),
      );

      day++;
      currentWeekday++;
    }

    // Fill remaining cells
    while (rowChildren.length < 7) {
      rowChildren.add(pw.SizedBox(width: 14));
    }
    rows.add(pw.Row(children: rowChildren));

    return rows;
  }

  /// Format DateTime for iCal (YYYYMMDDTHHMMSSZ in UTC)
  String _formatIcalDateTime(DateTime dateTime) {
    final utc = dateTime.toUtc();
    return '${DateFormat('yyyyMMddTHHmmss').format(utc)}Z';
  }

  /// Escape special characters for iCal text fields
  String _escapeIcalText(String text) {
    return text
        .replaceAll('\\', '\\\\')
        .replaceAll(',', '\\,')
        .replaceAll(';', '\\;')
        .replaceAll('\n', '\\n');
  }

  /// Convert hex color string to PdfColor
  PdfColor _hexToPdfColor(String hexColor) {
    // Remove # if present
    final hex = hexColor.replaceAll('#', '');

    // Parse RGB values
    final r = int.parse(hex.substring(0, 2), radix: 16) / 255;
    final g = int.parse(hex.substring(2, 4), radix: 16) / 255;
    final b = int.parse(hex.substring(4, 6), radix: 16) / 255;

    return PdfColor(r, g, b);
  }
}
