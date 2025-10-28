import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../Models/visitor_event.dart';

class RealtimeEventsScreen extends StatefulWidget {
  const RealtimeEventsScreen({super.key});

  @override
  State<RealtimeEventsScreen> createState() => _RealtimeEventsScreenState();
}

class _RealtimeEventsScreenState extends State<RealtimeEventsScreen> {
  final List<Map<String, dynamic>> _events = [];
  RealtimeChannel? _channel;
  bool _isListening = false;
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasInitialized) {
      _hasInitialized = true;
      _startRealtimeListener();
    }
  }

  @override
  void dispose() {
    _stopRealtimeListener();
    super.dispose();
  }

  void _startRealtimeListener() {
    if (_isListening) return;

    _channel = Supabase.instance.client
        .channel('drop_off_events_channel')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'drop_off_events',
          callback: (payload) {
            _handleRealtimeEvent(payload);
          },
        )
        .subscribe();

    setState(() {
      _isListening = true;
    });

    // Show confirmation that listener started - defer until after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📡 Escuchando eventos en tiempo real...'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  void _stopRealtimeListener() {
    if (_channel != null) {
      Supabase.instance.client.removeChannel(_channel!);
      _channel = null;
    }

    // Only call setState if the widget is still mounted
    if (mounted) {
      setState(() {
        _isListening = false;
      });
    } else {
      // If not mounted, just update the variable directly
      _isListening = false;
    }
  }

  void _handleRealtimeEvent(PostgresChangePayload payload) {
    if (!mounted) return;

    final eventType = payload.eventType;
    final newRecord = payload.newRecord;
    final oldRecord = payload.oldRecord;

    VisitorEvent? visitorEvent;
    VisitorEvent? oldVisitorEvent;

    // Try to parse the new record as a VisitorEvent
    try {
      if (newRecord.isNotEmpty) {
        visitorEvent = VisitorEvent.fromJson(newRecord);
      }
      if (oldRecord.isNotEmpty) {
        oldVisitorEvent = VisitorEvent.fromJson(oldRecord);
      }
    } catch (e) {
      // If parsing fails, we'll still show the raw data
      print('Error parsing visitor event: $e');
    }

    setState(() {
      final event = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'timestamp': DateTime.now(),
        'eventType': eventType.toString().split('.').last,
        'newRecord': newRecord,
        'oldRecord': oldRecord,
        'visitorEvent': visitorEvent,
        'oldVisitorEvent': oldVisitorEvent,
      };

      _events.insert(0, event); // Add to beginning of list

      // Keep only last 50 events to prevent memory issues
      if (_events.length > 50) {
        _events.removeLast();
      }
    });

    // Show notification for new events
    _showEventNotification(eventType, visitorEvent);
  }

  void _showEventNotification(
    PostgresChangeEvent eventType,
    VisitorEvent? visitorEvent,
  ) {
    String message;
    Color backgroundColor;
    IconData icon;

    // Create a user-friendly message based on the visitor event
    if (visitorEvent != null) {
      switch (eventType) {
        case PostgresChangeEvent.insert:
          message = '👋 ${visitorEvent.visitorName} ha llegado';
          backgroundColor = Colors.green;
          icon = Icons.person_add;
          break;
        case PostgresChangeEvent.update:
          message = '📝 Registro de ${visitorEvent.visitorName} actualizado';
          backgroundColor = Colors.blue;
          icon = Icons.edit;
          break;
        case PostgresChangeEvent.delete:
          message = '🚪 Registro de ${visitorEvent.visitorName} eliminado';
          backgroundColor = Colors.red;
          icon = Icons.person_remove;
          break;
        default:
          message = '📝 Evento de ${visitorEvent.visitorName}';
          backgroundColor = Colors.grey;
          icon = Icons.info;
      }
    } else {
      // Fallback to generic messages
      switch (eventType) {
        case PostgresChangeEvent.insert:
          message = 'Nuevo registro agregado';
          backgroundColor = Colors.green;
          icon = Icons.add_circle;
          break;
        case PostgresChangeEvent.update:
          message = 'Registro actualizado';
          backgroundColor = Colors.blue;
          icon = Icons.edit;
          break;
        case PostgresChangeEvent.delete:
          message = 'Registro eliminado';
          backgroundColor = Colors.red;
          icon = Icons.delete;
          break;
        default:
          message = 'Evento recibido';
          backgroundColor = Colors.grey;
          icon = Icons.info;
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: backgroundColor,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _clearEvents() {
    setState(() {
      _events.clear();
    });
  }

  String _getEventTypeDisplayText(String eventType) {
    switch (eventType.toLowerCase()) {
      case 'insert':
        return 'Nuevo';
      case 'update':
        return 'Actualización';
      case 'delete':
        return 'Eliminado';
      default:
        return eventType.toUpperCase();
    }
  }

  String _getEventTypeIcon(String eventType) {
    switch (eventType.toLowerCase()) {
      case 'insert':
        return '➕';
      case 'update':
        return '✏️';
      case 'delete':
        return '🗑️';
      default:
        return '📝';
    }
  }

  Color _getEventTypeColor(String eventType) {
    switch (eventType.toLowerCase()) {
      case 'insert':
        return Colors.green;
      case 'update':
        return Colors.blue;
      case 'delete':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'Ahora';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.day}/${timestamp.month} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Eventos en Tiempo Real'),
        actions: [
          // Listener status indicator
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _isListening
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isListening ? Colors.green : Colors.red,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _isListening ? Colors.green : Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _isListening ? 'Conectado' : 'Desconectado',
                  style: textTheme.bodySmall?.copyWith(
                    color: _isListening ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'clear':
                  _clearEvents();
                  break;
                case 'toggle':
                  if (_isListening) {
                    _stopRealtimeListener();
                  } else {
                    _startRealtimeListener();
                  }
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'toggle',
                child: Row(
                  children: [
                    Icon(_isListening ? Icons.stop : Icons.play_arrow),
                    const SizedBox(width: 8),
                    Text(_isListening ? 'Detener' : 'Iniciar'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.clear_all),
                    SizedBox(width: 8),
                    Text('Limpiar'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Info Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.primary.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: colorScheme.primary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Eventos en tiempo real',
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.primary,
                        ),
                      ),
                      Text(
                        'Eventos: ${_events.length} | Estado: ${_isListening ? "Escuchando" : "Pausado"}',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Events List
          Expanded(
            child: _events.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _events.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final event = _events[index];
                      return _buildEventCard(event);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.radio_button_checked,
            size: 64,
            color: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            _isListening ? 'Esperando eventos...' : 'Listener desconectado',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isListening
                ? 'Los eventos de la tabla drop_off_events aparecerán aquí'
                : 'Toca el menú superior para iniciar el listener',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    final theme = Theme.of(context);
    final eventType = event['eventType'] as String;
    final timestamp = event['timestamp'] as DateTime;
    final visitorEvent = event['visitorEvent'] as VisitorEvent?;
    final visitorName = event['newRecord']['visitor_name'] as String;

    // Get main display text
    String mainText;
    String subText;

    if (visitorEvent != null) {
      mainText = visitorEvent.visitorName;
      subText =
          '${visitorEvent.schoolDestination} • ${visitorEvent.statusDescription}';
    } else {
      mainText = 'Registro $visitorName';
      subText = 'Ver detalles para más información';
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _getEventTypeColor(eventType).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => _showEventDetails(event),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with event type and timestamp
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getEventTypeColor(eventType).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _getEventTypeIcon(eventType),
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getEventTypeDisplayText(eventType),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: _getEventTypeColor(eventType),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatTimestamp(timestamp),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Main content
              Text(
                mainText,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              if (subText.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  subText,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // Additional visitor info if available
              if (visitorEvent != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (visitorEvent.isCommunityMemberVisit) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'FAMILIA OXS',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Text(
                        '${visitorEvent.identificationType} ${visitorEvent.identificationNumber}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showEventDetails(Map<String, dynamic> event) {
    final visitorEvent = event['visitorEvent'] as VisitorEvent?;
    final oldVisitorEvent = event['oldVisitorEvent'] as VisitorEvent?;
    final eventType = event['eventType'] as String;
    final timestamp = event['timestamp'] as DateTime;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(_getEventTypeIcon(eventType)),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Evento: ${_getEventTypeDisplayText(eventType)}'),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Fecha:', _formatDetailTimestamp(timestamp)),
              const SizedBox(height: 16),

              if (visitorEvent != null) ...[
                const Text(
                  '👤 Información del Visitante',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                _buildVisitorDetailsCard(visitorEvent, Colors.green),
              ] else ...[
                const Text(
                  '📋 Información del Evento',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildRawDataCard(event['newRecord']),
              ],

              if (oldVisitorEvent != null) ...[
                const SizedBox(height: 16),
                const Text(
                  '📝 Estado Anterior',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                _buildVisitorDetailsCard(oldVisitorEvent, Colors.orange),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitorDetailsCard(VisitorEvent visitor, Color borderColor) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 400), // Limit height
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: borderColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor.withOpacity(0.3)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name and status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        visitor.visitorName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(
                            visitor.status,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          visitor.statusDescription,
                          style: TextStyle(
                            color: _getStatusColor(visitor.status),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (visitor.isCommunityMemberVisit)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'FAMILIA OXS',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Details grid
            ..._buildDetailRows([
              ('🏫 Destino', visitor.schoolDestination),
              ('🆔 Identificación', '${visitor.identificationNumber}'),
              ('🆔 Tipo ID', '${visitor.identificationType}'),
              ('🎯 Motivo', visitor.reasonForVisit),
              ('📅 Llegada', visitor.formattedArrivalDateTime),
              ('👤 Registrado por: ', visitor.createdBy.toString()),
              if (visitor.hasLeft)
                ('🚪 Salida', visitor.formattedLeaveDateTime ?? 'N/A'),
              if (visitor.observations.isNotEmpty)
                ('📝 Observaciones', visitor.observations),
              ('📱 Dispositivo', visitor.device),
              (
                '🏠 Miembro de comunidad Oxs',
                visitor.communityMember.toString(),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDetailRows(List<(String, String)> details) {
    return details.map((detail) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 100,
              child: Text(
                detail.$1,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
            Expanded(
              child: Text(detail.$2, style: const TextStyle(fontSize: 13)),
            ),
          ],
        ),
      );
    }).toList();
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 0:
        return Colors.red; // Cancelado
      case 1:
        return Colors.green; // Ingreso registrado
      case 2:
        return Colors.blue; // Confirmado
      case 3:
        return Colors.orange; // Agendado
      case 4:
        return Colors.purple; // Salida registrada
      default:
        return Colors.grey;
    }
  }

  Widget _buildRawDataCard(Map<String, dynamic> data) {
    // Extract key information for user-friendly display
    final visitorName = data['visitor_name'] ?? 'Nombre no disponible';
    final status = data['status'] as int?;
    final schoolDestination =
        data['school_destination'] ?? 'Destino no especificado';
    final identificationType = data['identification_type'] ?? '';
    final identificationNumber =
        data['identification_number'] ?? data['identificationNumber'] ?? '';
    final reasonForVisit = data['reason_for_visit'] ?? 'No especificado';
    final arriveDate = data['arrive_date'];
    final leaveDate = data['leave_date'];
    final communityMember = data['is_community_member'] as bool? ?? false;
    final createdBy = data['created_by'] ?? 'Desconocido';
    final device = data['device'] ?? 'Desconocido';

    // Get status description with custom messages
    String statusDescription;
    Color statusColor;
    switch (status) {
      case 1:
        statusDescription = 'Ingreso al campus registrado';
        statusColor = Colors.green;
        break;
      case 4:
        statusDescription = 'Salida registrada';
        statusColor = Colors.purple;
        break;
      case 0:
        statusDescription = 'Cancelado';
        statusColor = Colors.red;
        break;
      case 2:
        statusDescription = 'Confirmado x destino';
        statusColor = Colors.blue;
        break;
      case 3:
        statusDescription = 'Agendado';
        statusColor = Colors.orange;
        break;
      default:
        statusDescription = 'Estado desconocido';
        statusColor = Colors.grey;
    }

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 350), // Limit height
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with name and status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        visitorName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          statusDescription,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (communityMember)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'FAMILIA OXS',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Information details
            ..._buildSimpleDetailRows([
              ('🏫 Destino', schoolDestination),
              if (identificationType.isNotEmpty ||
                  identificationNumber.toString().isNotEmpty)
                ('🆔 ID', '$identificationType'),
              ('🆔 Tipo ID', '$identificationNumber'),
              ('👤 Registró: ', '$createdBy'),
              ('📱 Dispositivo', device),
              ('🎯 Motivo', reasonForVisit),
              if (arriveDate != null)
                ('📅 Llegada', _formatApiDate(arriveDate.toString())),
              if (leaveDate != null)
                ('🚪 Salida', _formatApiDate(leaveDate.toString())),
              ('🏠 Familia Oxs', communityMember ? 'Sí' : 'No'),
            ]),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSimpleDetailRows(List<(String, String)> details) {
    return details.map((detail) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 99,
              child: Text(
                detail.$1,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
            Expanded(
              child: Text(detail.$2, style: const TextStyle(fontSize: 13)),
            ),
          ],
        ),
      );
    }).toList();
  }

  String _formatApiDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString; // Return original if parsing fails
    }
  }

  String _formatDetailTimestamp(DateTime timestamp) {
    return '${timestamp.day}/${timestamp.month}/${timestamp.year} a las ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}';
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
