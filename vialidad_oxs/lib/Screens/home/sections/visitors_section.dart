import 'package:flutter/material.dart';
import 'package:vialidad_oxs/Services/visitorsService.dart';
import 'package:vialidad_oxs/config/temp/temp_data.dart';
import '../../../Models/visitor_event.dart';

class VisitorsSection extends StatefulWidget {
  const VisitorsSection({super.key});

  @override
  State<VisitorsSection> createState() => _VisitorsSectionState();
}

class _VisitorsSectionState extends State<VisitorsSection> {
  final _formKey = GlobalKey<FormState>();
  final _visitorNameController = TextEditingController();
  final _destinationController = TextEditingController();
  final _motiveController = TextEditingController();
  final _observationsController = TextEditingController();
  final _identificationNumberController = TextEditingController();

  String? _selectedIdentificationType;
  String? _selectedCampus;
  bool _isCommunityMember = false;
  bool _isLoading = false;

  // Accessibility settings
  double _fontSizeMultiplier = 1.0;
  bool _highContrast = false;

  // Predefined identification types
  final List<String> _identificationTypes = [
    'INE',
    'Pasaporte',
    'Licencia de Conducir',
    'Credencial Estudiante',
    'Credencial Empleado',
    'Cartelon',
    'Otro',
  ];

  // Campus options
  final List<String> _campusOptions = [
    'BARRAGAN',
    'SENDERO',
    'CONCORDIA',
    'ANAHUAC',
  ];

  @override
  void dispose() {
    _visitorNameController.dispose();
    _destinationController.dispose();
    _motiveController.dispose();
    _observationsController.dispose();
    _identificationNumberController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _visitorNameController.clear();
    _destinationController.clear();
    _motiveController.clear();
    _observationsController.clear();
    _identificationNumberController.clear();
    setState(() {
      _selectedIdentificationType = null;
      _selectedCampus = null;
      _isCommunityMember = false;
    });
  }

  void _increaseFontSize() {
    setState(() {
      _fontSizeMultiplier = (_fontSizeMultiplier + 0.2).clamp(0.8, 2.0);
    });
  }

  void _decreaseFontSize() {
    setState(() {
      _fontSizeMultiplier = (_fontSizeMultiplier - 0.2).clamp(0.8, 2.0);
    });
  }

  void _toggleHighContrast() {
    setState(() {
      _highContrast = !_highContrast;
    });
  }

  // Get accessible text style
  TextStyle? _getAccessibleTextStyle(TextStyle? baseStyle) {
    if (baseStyle == null) return null;
    return baseStyle.copyWith(
      fontSize: (baseStyle.fontSize ?? 14) * _fontSizeMultiplier,
      fontWeight: _highContrast ? FontWeight.bold : baseStyle.fontWeight,
    );
  }

  // Get accessible input decoration with larger touch targets
  InputDecoration _getAccessibleInputDecoration({
    required String labelText,
    required String hintText,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: Icon(icon, size: 24 * _fontSizeMultiplier),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          width: _highContrast ? 2.0 : 1.0,
          color: _highContrast ? Colors.black : Colors.grey,
        ),
      ),
      contentPadding: EdgeInsets.all(16 * _fontSizeMultiplier),
      labelStyle: TextStyle(
        fontSize: 16 * _fontSizeMultiplier,
        fontWeight: _highContrast ? FontWeight.bold : FontWeight.normal,
        color: _highContrast ? Colors.black : null,
      ),
      hintStyle: TextStyle(
        fontSize: 14 * _fontSizeMultiplier,
        color: _highContrast ? Colors.black54 : null,
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedIdentificationType == null) {
      _showErrorSnackBar('Por favor selecciona un tipo de identificación');
      return;
    }

    if (_selectedCampus == null) {
      _showErrorSnackBar('Por favor selecciona un campus');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create the visitor event object
      final visitorEvent = VisitorEvent(
        creationDate: DateTime.now(),
        visitorName: _visitorNameController.text.trim(),
        identificationType: _selectedIdentificationType!,
        schoolDestination: _destinationController.text.trim(),
        reasonForVisit: _motiveController.text.trim(),
        arriveDate: DateTime.now(),
        observations: _observationsController.text.trim(),
        createdBy: tempUser!.employeeNumber,
        device: deviceData['name'], // Using campus as device for now
        status: 1, // Ingreso registrado
        identificationNumber:
            int.tryParse(_identificationNumberController.text.trim()) ?? 0,
        communityMember: _isCommunityMember,
      );

      // Call visitors service to submit the visitor registration
      final visitorsService = VisitorsService();
      final response = await visitorsService.registerVisitor(visitorEvent);

      if (response.success) {
        _showSuccessSnackBar(
          response.message.isNotEmpty
              ? response.message
              : 'Visitante registrado exitosamente',
        );
        _resetForm();
      } else {
        _showErrorSnackBar(response.error ?? 'Error al registrar visitante');
      }

      // Log the visitor event for debugging (remove this in production)
      debugPrint('Visitor event created: ${visitorEvent.toString()}');
    } catch (e) {
      _showErrorSnackBar('Error al registrar visitante: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Registrar Visitante',
          style: _getAccessibleTextStyle(theme.textTheme.titleLarge),
        ),
        backgroundColor: _highContrast
            ? Colors.white
            : theme.colorScheme.primaryContainer,
        foregroundColor: _highContrast ? Colors.black : null,
        actions: [
          // Accessibility controls
          PopupMenuButton<String>(
            icon: Icon(
              Icons.accessibility,
              size: 28 * _fontSizeMultiplier,
              color: _highContrast ? Colors.black : null,
            ),
            tooltip: 'Opciones de Accesibilidad',
            onSelected: (value) {
              switch (value) {
                case 'increase_font':
                  _increaseFontSize();
                  break;
                case 'decrease_font':
                  _decreaseFontSize();
                  break;
                case 'high_contrast':
                  _toggleHighContrast();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'increase_font',
                child: Row(
                  children: [
                    const Icon(Icons.zoom_in),
                    const SizedBox(width: 8),
                    Text(
                      'Aumentar Texto',
                      style: TextStyle(fontSize: 16 * _fontSizeMultiplier),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'decrease_font',
                child: Row(
                  children: [
                    const Icon(Icons.zoom_out),
                    const SizedBox(width: 8),
                    Text(
                      'Reducir Texto',
                      style: TextStyle(fontSize: 16 * _fontSizeMultiplier),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'high_contrast',
                child: Row(
                  children: [
                    Icon(
                      _highContrast ? Icons.contrast : Icons.contrast_outlined,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _highContrast ? 'Contraste Normal' : 'Alto Contraste',
                      style: TextStyle(fontSize: 16 * _fontSizeMultiplier),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      backgroundColor: _highContrast ? Colors.white : null,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header card
              Card(
                elevation: _highContrast ? 4 : 0,
                color: _highContrast
                    ? Colors.grey[100]
                    : theme.colorScheme.primaryContainer.withOpacity(0.3),
                child: Padding(
                  padding: EdgeInsets.all(20 * _fontSizeMultiplier),
                  child: Row(
                    children: [
                      Icon(
                        Icons.person_add,
                        color: _highContrast
                            ? Colors.black
                            : theme.colorScheme.primary,
                        size: 28 * _fontSizeMultiplier,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Nuevo Visitante',
                              style: _getAccessibleTextStyle(
                                theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: _highContrast
                                      ? Colors.black
                                      : theme.colorScheme.primary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Complete la información del visitante',
                              style: _getAccessibleTextStyle(
                                theme.textTheme.bodyMedium?.copyWith(
                                  color: _highContrast
                                      ? Colors.black87
                                      : theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24 * _fontSizeMultiplier),

              // Visitor Name
              TextFormField(
                controller: _visitorNameController,
                decoration: _getAccessibleInputDecoration(
                  labelText: 'Nombre del Visitante *',
                  hintText: 'Ingrese el nombre completo',
                  icon: Icons.person,
                ),
                style: TextStyle(
                  fontSize: 18 * _fontSizeMultiplier,
                  fontWeight: _highContrast
                      ? FontWeight.w500
                      : FontWeight.normal,
                  color: _highContrast ? Colors.black : null,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Este campo es obligatorio';
                  }
                  if (value.trim().length < 2) {
                    return 'El nombre debe tener al menos 2 caracteres';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.words,
              ),

              SizedBox(height: 20 * _fontSizeMultiplier),

              // Identification Type Dropdown
              Container(
                decoration: BoxDecoration(
                  border: _highContrast
                      ? Border.all(color: Colors.black, width: 2)
                      : null,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonFormField<String>(
                  value: _selectedIdentificationType,
                  decoration: _getAccessibleInputDecoration(
                    labelText: 'Tipo de Identificación *',
                    hintText: 'Seleccione el tipo de ID',
                    icon: Icons.badge,
                  ),
                  style: TextStyle(
                    fontSize: 16 * _fontSizeMultiplier,
                    fontWeight: _highContrast
                        ? FontWeight.w500
                        : FontWeight.normal,
                    color: _highContrast ? Colors.black : Colors.black87,
                  ),
                  dropdownColor: _highContrast ? Colors.white : null,
                  isDense: false,
                  isExpanded: true,
                  menuMaxHeight: 300 * _fontSizeMultiplier,
                  items: _identificationTypes.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Container(
                        constraints: BoxConstraints(
                          minHeight: 40 * _fontSizeMultiplier,
                        ),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          type,
                          style: TextStyle(
                            fontSize: 16 * _fontSizeMultiplier,
                            fontWeight: _highContrast
                                ? FontWeight.w500
                                : FontWeight.normal,
                            color: _highContrast
                                ? Colors.black
                                : Colors.black87,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedIdentificationType = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor seleccione un tipo de identificación';
                    }
                    return null;
                  },
                ),
              ),

              SizedBox(height: 20 * _fontSizeMultiplier),

              // Identification Number (Optional)
              TextFormField(
                controller: _identificationNumberController,
                decoration: _getAccessibleInputDecoration(
                  labelText: 'Número de Identificación (Opcional)',
                  hintText: 'Ingrese el número de ID',
                  icon: Icons.numbers,
                ),
                style: TextStyle(
                  fontSize: 18 * _fontSizeMultiplier,
                  fontWeight: _highContrast
                      ? FontWeight.w500
                      : FontWeight.normal,
                  color: _highContrast ? Colors.black : null,
                ),
                keyboardType: TextInputType.number,
              ),

              SizedBox(height: 20 * _fontSizeMultiplier),

              // Campus Selector
              Container(
                decoration: BoxDecoration(
                  border: _highContrast
                      ? Border.all(color: Colors.black, width: 2)
                      : null,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonFormField<String>(
                  value: _selectedCampus,
                  decoration: _getAccessibleInputDecoration(
                    labelText: 'Campus *',
                    hintText: 'Seleccione el campus',
                    icon: Icons.school,
                  ),
                  style: TextStyle(
                    fontSize: 16 * _fontSizeMultiplier,
                    fontWeight: _highContrast
                        ? FontWeight.w500
                        : FontWeight.normal,
                    color: _highContrast ? Colors.black : Colors.black87,
                  ),
                  dropdownColor: _highContrast ? Colors.white : null,
                  isDense: false,
                  isExpanded: true,
                  menuMaxHeight: 300 * _fontSizeMultiplier,
                  items: _campusOptions.map((String campus) {
                    return DropdownMenuItem<String>(
                      value: campus,
                      child: Container(
                        constraints: BoxConstraints(
                          minHeight: 40 * _fontSizeMultiplier,
                        ),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          campus,
                          style: TextStyle(
                            fontSize: 16 * _fontSizeMultiplier,
                            fontWeight: _highContrast
                                ? FontWeight.w500
                                : FontWeight.normal,
                            color: _highContrast
                                ? Colors.black
                                : Colors.black87,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCampus = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor seleccione un campus';
                    }
                    return null;
                  },
                ),
              ),

              SizedBox(height: 20 * _fontSizeMultiplier),

              // Destination (Office)
              TextFormField(
                controller: _destinationController,
                decoration: _getAccessibleInputDecoration(
                  labelText: 'Destino (Oficina) *',
                  hintText: 'Ej: Rectoría, Aula 101, Laboratorio',
                  icon: Icons.location_on,
                ),
                style: TextStyle(
                  fontSize: 18 * _fontSizeMultiplier,
                  fontWeight: _highContrast
                      ? FontWeight.w500
                      : FontWeight.normal,
                  color: _highContrast ? Colors.black : null,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Este campo es obligatorio';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.words,
              ),

              SizedBox(height: 20 * _fontSizeMultiplier),

              // Motive
              TextFormField(
                controller: _motiveController,
                decoration: _getAccessibleInputDecoration(
                  labelText: 'Motivo de la Visita *',
                  hintText: 'Ej: Reunión, Entrevista, Evento',
                  icon: Icons.assignment,
                ),
                style: TextStyle(
                  fontSize: 18 * _fontSizeMultiplier,
                  fontWeight: _highContrast
                      ? FontWeight.w500
                      : FontWeight.normal,
                  color: _highContrast ? Colors.black : null,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Este campo es obligatorio';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.sentences,
              ),

              SizedBox(height: 20 * _fontSizeMultiplier),

              // Observations
              TextFormField(
                controller: _observationsController,
                decoration: _getAccessibleInputDecoration(
                  labelText: 'Observaciones (Opcional)',
                  hintText: 'Información adicional sobre la visita',
                  icon: Icons.note,
                ),
                style: TextStyle(
                  fontSize: 18 * _fontSizeMultiplier,
                  fontWeight: _highContrast
                      ? FontWeight.w500
                      : FontWeight.normal,
                  color: _highContrast ? Colors.black : null,
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),

              SizedBox(height: 20 * _fontSizeMultiplier),

              // Community Member Switch
              Card(
                elevation: _highContrast ? 4 : 0,
                color: _highContrast
                    ? Colors.grey[100]
                    : theme.colorScheme.surfaceVariant.withOpacity(0.3),
                child: Padding(
                  padding: EdgeInsets.all(20 * _fontSizeMultiplier),
                  child: Row(
                    children: [
                      Icon(
                        Icons.groups,
                        color: _highContrast
                            ? Colors.black
                            : theme.colorScheme.onSurfaceVariant,
                        size: 28 * _fontSizeMultiplier,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Miembro de la Comunidad',
                              style: _getAccessibleTextStyle(
                                theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: _highContrast ? Colors.black : null,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Indica si es miembro de la comunidad Oxschool',
                              style: _getAccessibleTextStyle(
                                theme.textTheme.bodyMedium?.copyWith(
                                  color: _highContrast
                                      ? Colors.black87
                                      : theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Transform.scale(
                        scale: 1.2 * _fontSizeMultiplier,
                        child: Switch(
                          value: _isCommunityMember,
                          onChanged: (bool value) {
                            setState(() {
                              _isCommunityMember = value;
                            });
                          },
                          activeColor: _highContrast ? Colors.black : null,
                          inactiveThumbColor: _highContrast
                              ? Colors.grey[600]
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 32 * _fontSizeMultiplier),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 64 * _fontSizeMultiplier,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _highContrast
                        ? Colors.black
                        : theme.colorScheme.primary,
                    foregroundColor: _highContrast
                        ? Colors.white
                        : theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: _highContrast
                          ? const BorderSide(color: Colors.black, width: 2)
                          : BorderSide.none,
                    ),
                    elevation: _highContrast ? 8 : 2,
                  ),
                  child: _isLoading
                      ? SizedBox(
                          width: 28 * _fontSizeMultiplier,
                          height: 28 * _fontSizeMultiplier,
                          child: const CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_add,
                              size: 24 * _fontSizeMultiplier,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Registrar Visitante',
                              style: TextStyle(
                                fontSize: 18 * _fontSizeMultiplier,
                                fontWeight: FontWeight.w600,
                                color: _highContrast ? Colors.white : null,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              SizedBox(height: 16 * _fontSizeMultiplier),

              // Reset Button
              SizedBox(
                width: double.infinity,
                height: 56 * _fontSizeMultiplier,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : _resetForm,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: _highContrast
                          ? Colors.black
                          : theme.colorScheme.outline,
                      width: _highContrast ? 2 : 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.refresh,
                        size: 22 * _fontSizeMultiplier,
                        color: _highContrast ? Colors.black : null,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Limpiar Formulario',
                        style: TextStyle(
                          fontSize: 16 * _fontSizeMultiplier,
                          fontWeight: FontWeight.w600,
                          color: _highContrast ? Colors.black : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24 * _fontSizeMultiplier),

              // Required fields note
              Container(
                padding: EdgeInsets.all(16 * _fontSizeMultiplier),
                decoration: BoxDecoration(
                  color: _highContrast
                      ? Colors.grey[200]
                      : theme.colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: _highContrast
                      ? Border.all(color: Colors.black, width: 1)
                      : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20 * _fontSizeMultiplier,
                      color: _highContrast
                          ? Colors.black
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '* Campos obligatorios',
                        style: _getAccessibleTextStyle(
                          theme.textTheme.bodyMedium?.copyWith(
                            color: _highContrast
                                ? Colors.black
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
