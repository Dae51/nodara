import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:nodara/data/models/opportunity.dart';
import 'package:nodara/features/auth/auth_provider.dart';
import 'package:nodara/features/organization/organization_provider.dart';
import 'package:nodara/theme/app_colors.dart';
import 'package:nodara/theme/app_theme.dart';

/// Pantalla con formulario para crear o editar una convocatoria de voluntariado.
class OpportunityFormScreen extends StatefulWidget {
  const OpportunityFormScreen({super.key, this.opportunity});

  final Opportunity? opportunity;

  @override
  State<OpportunityFormScreen> createState() => _OpportunityFormScreenState();
}

class _OpportunityFormScreenState extends State<OpportunityFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _tituloController;
  late final TextEditingController _descripcionController;
  late final TextEditingController _ubicacionController;
  late final TextEditingController _horarioController;
  late final TextEditingController _compromisoController;
  late final TextEditingController _cuposController;
  late final TextEditingController _horasController;
  late final TextEditingController _requisitosController;

  late Causa _causa;
  late Formato _formato;
  late Modalidad _modalidad;
  late DateTime _cierreInscripcion;
  bool _autoValidate = false;

  bool get _esEdicion => widget.opportunity != null;

  @override
  void initState() {
    super.initState();
    final opp = widget.opportunity;

    _tituloController = TextEditingController(text: opp?.titulo ?? '');
    _descripcionController = TextEditingController(
      text: opp?.descripcion ?? '',
    );
    _ubicacionController = TextEditingController(
      text: opp != null ? opp.ubicacion : 'San Salvador',
    );
    _horarioController = TextEditingController(
      text: opp?.horario ?? 'Sábados de 8:00 a 12:00',
    );
    _compromisoController = TextEditingController(
      text: opp?.compromiso ?? '4 semanas',
    );
    _cuposController = TextEditingController(
      text: opp != null ? opp.cuposTotal.toString() : '10',
    );
    _horasController = TextEditingController(
      text: opp != null ? opp.horasEstimadas.toString() : '20',
    );
    _requisitosController = TextEditingController(
      text: opp != null ? opp.requisitos.join('\n') : '',
    );

    _causa = opp?.causa ?? Causa.comunidades;
    _formato = opp?.formato ?? Formato.jornada;
    _modalidad = opp?.modalidad ?? Modalidad.presencial;
    _cierreInscripcion =
        opp?.cierreInscripcion ?? DateTime.now().add(const Duration(days: 14));
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _ubicacionController.dispose();
    _horarioController.dispose();
    _compromisoController.dispose();
    _cuposController.dispose();
    _horasController.dispose();
    _requisitosController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFechaCierre() async {
    final hoy = DateTime.now();
    final fechaInicial = _cierreInscripcion.isBefore(hoy)
        ? hoy
        : _cierreInscripcion;

    final fecha = await showDatePicker(
      context: context,
      initialDate: fechaInicial,
      firstDate: hoy,
      lastDate: hoy.add(const Duration(days: 365)),
    );

    if (fecha != null && mounted) {
      setState(() => _cierreInscripcion = fecha);
    }
  }

  Future<void> _guardar() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      setState(() => _autoValidate = true);
      return;
    }

    final orgProvider = context.read<OrganizationProvider>();
    final user = context.read<AuthProvider>().user;
    final orgId = orgProvider.orgId.isNotEmpty
        ? orgProvider.orgId
        : (user?.uid ?? (widget.opportunity?.orgId ?? ''));
    final orgNombre =
        user?.nombre ?? (widget.opportunity?.orgNombre ?? 'Mi Organización');

    final cupos = int.tryParse(_cuposController.text.trim()) ?? 1;
    final horas = int.tryParse(_horasController.text.trim()) ?? 1;
    final reqs = _requisitosController.text
        .split('\n')
        .map((r) => r.trim())
        .where((r) => r.isNotEmpty)
        .toList();

    final opp = Opportunity(
      id: widget.opportunity?.id ?? '',
      orgId: orgId,
      orgNombre: orgNombre,
      titulo: _tituloController.text.trim(),
      tituloCorto: _tituloController.text.trim(),
      descripcion: _descripcionController.text.trim(),
      causa: _causa,
      formato: _formato,
      modalidad: _modalidad,
      etiqueta: '${_causa.label} · ${_formato.label}',
      departamento: _ubicacionController.text.trim(),
      ubicacion: _ubicacionController.text.trim(),
      direccion: _ubicacionController.text.trim(),
      horario: _horarioController.text.trim(),
      compromiso: _compromisoController.text.trim(),
      cierreInscripcion: _cierreInscripcion,
      horasEstimadas: horas,
      cuposTotal: cupos,
      cuposOcupados: widget.opportunity?.cuposOcupados ?? 0,
      requisitos: reqs.isEmpty ? const ['Disponibilidad y compromiso'] : reqs,
      beneficios: widget.opportunity?.beneficios ?? const [],
      imagenUrl: widget.opportunity?.imagenUrl ?? '',
      activa: widget.opportunity?.activa ?? true,
    );

    final exito = await context
        .read<OrganizationProvider>()
        .guardarConvocatoria(opp, esEdicion: _esEdicion);

    if (!mounted) return;

    if (exito) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _esEdicion
                ? 'Convocatoria actualizada correctamente'
                : 'Convocatoria publicada correctamente',
          ),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pop();
    } else {
      final error = context.read<OrganizationProvider>().error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Error al guardar la convocatoria'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = context.watch<OrganizationProvider>().isSaving;
    final fechaTexto =
        '${_cierreInscripcion.day.toString().padLeft(2, '0')}/${_cierreInscripcion.month.toString().padLeft(2, '0')}/${_cierreInscripcion.year}';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _esEdicion ? 'Editar convocatoria' : 'Nueva convocatoria',
          style: AppTextStyles.titleLg,
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          autovalidateMode: _autoValidate
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              Text('Información general', style: AppTextStyles.titleMd),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(
                  labelText: 'Título de la convocatoria *',
                  hintText: 'Ej. Reforestación El Boquerón',
                ),
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'Ingresa un título para la convocatoria';
                  }
                  if (valor.trim().length < 4) {
                    return 'El título debe tener al menos 4 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _descripcionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descripción *',
                  hintText: 'Describe el objetivo del voluntariado y qué actividades harán...',
                ),
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'Ingresa una descripción';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<Causa>(
                initialValue: _causa,
                decoration: const InputDecoration(labelText: 'Causa *'),
                items: Causa.values.map((c) {
                  return DropdownMenuItem(value: c, child: Text(c.label));
                }).toList(),
                onChanged: (nueva) {
                  if (nueva != null) setState(() => _causa = nueva);
                },
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<Formato>(
                      initialValue: _formato,
                      decoration: const InputDecoration(labelText: 'Formato *'),
                      items: Formato.values.map((f) {
                        return DropdownMenuItem(value: f, child: Text(f.label));
                      }).toList(),
                      onChanged: (nuevo) {
                        if (nuevo != null) setState(() => _formato = nuevo);
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: DropdownButtonFormField<Modalidad>(
                      initialValue: _modalidad,
                      decoration: const InputDecoration(
                        labelText: 'Modalidad *',
                      ),
                      items: Modalidad.values.map((m) {
                        return DropdownMenuItem(value: m, child: Text(m.label));
                      }).toList(),
                      onChanged: (nueva) {
                        if (nueva != null) setState(() => _modalidad = nueva);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Logística y fechas', style: AppTextStyles.titleMd),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _ubicacionController,
                decoration: const InputDecoration(
                  labelText: 'Ubicación / Departamento *',
                  hintText: 'Ej. San Salvador',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'Ingresa la ubicación';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _horarioController,
                      decoration: const InputDecoration(
                        labelText: 'Horario *',
                        hintText: 'Ej. 8:00 a 12:00',
                        prefixIcon: Icon(Icons.schedule_outlined),
                      ),
                      validator: (valor) {
                        if (valor == null || valor.trim().isEmpty) {
                          return 'Ingresa el horario';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: TextFormField(
                      controller: _compromisoController,
                      decoration: const InputDecoration(
                        labelText: 'Compromiso *',
                        hintText: 'Ej. 4 semanas',
                      ),
                      validator: (valor) {
                        if (valor == null || valor.trim().isEmpty) {
                          return 'Ingresa el compromiso';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              InkWell(
                onTap: _seleccionarFechaCierre,
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Cierre de inscripciones *',
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                    suffixIcon: Icon(Icons.edit_calendar_outlined),
                  ),
                  child: Text(fechaTexto, style: AppTextStyles.bodyMd),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Cupos y horas', style: AppTextStyles.titleMd),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cuposController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Cupos totales *',
                        prefixIcon: Icon(Icons.group_outlined),
                      ),
                      validator: (valor) {
                        final parsed = int.tryParse(valor ?? '');
                        if (parsed == null || parsed <= 0) {
                          return 'Mínimo 1 cupo';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: TextFormField(
                      controller: _horasController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Horas a acreditar *',
                        prefixIcon: Icon(Icons.timer_outlined),
                      ),
                      validator: (valor) {
                        final parsed = int.tryParse(valor ?? '');
                        if (parsed == null || parsed <= 0) {
                          return 'Mínimo 1 hora';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _requisitosController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Requisitos (uno por línea)',
                  hintText: 'Mayor de 16 años\nDisponibilidad de transporte',
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: isSaving ? null : _guardar,
                  child: isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _esEdicion
                              ? 'Guardar cambios'
                              : 'Publicar convocatoria',
                          style: AppTextStyles.titleSm.copyWith(
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
