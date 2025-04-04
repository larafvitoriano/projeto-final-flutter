import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:table_calendar/src/shared/utils.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<String>> _events = {}; // Mapa para armazenar eventos
  TextEditingController _eventTitleController = TextEditingController();
  TextEditingController _eventDescriptionController = TextEditingController();
  DateTime _selectedEventDate = DateTime.now(); // Data do evento selecionada no popup

  List<String> _getEventsForDay(DateTime day) {
    return _events[day] ?? [];
  }

  void _addEvent(DateTime date, String eventTitle, String eventDescription) {
    setState(() {
      if (_events[date] == null) {
        _events[date] = [];
      }
      _events[date]!.add('$eventTitle: $eventDescription');
    });
  }

  void _showAddEventDialog(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedEventDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedEventDate = pickedDate;
      });

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Adicionar Lembrete'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('Data: ${DateFormat('dd/MM/yyyy').format(_selectedEventDate)}'),
                TextField(
                  controller: _eventTitleController,
                  decoration: InputDecoration(labelText: 'Título'),
                ),
                TextField(
                  controller: _eventDescriptionController,
                  decoration: InputDecoration(labelText: 'Descrição'),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  _addEvent(
                    _selectedEventDate,
                    _eventTitleController.text,
                    _eventDescriptionController.text,
                  );
                  _eventTitleController.clear();
                  _eventDescriptionController.clear();
                  Navigator.of(context).pop();
                },
                child: Text('Salvar'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendário'),
      ),
      body: Column(
        children: <Widget>[
          TableCalendar(
            firstDay: DateTime.utc(2010, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              }
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            eventLoader: _getEventsForDay,
            locale: 'pt_BR',
          ),
          Expanded(
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return ListView(
                  children: _getEventsForDay(_selectedDay ?? _focusedDay)
                      .map((event) => ListTile(title: Text(event)))
                      .toList(),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEventDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }
}