import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/elevador_service.dart';
import '../models/elevador.dart';

class ElevadorFormScreen extends StatefulWidget {
  final Elevador? elevador;

  const ElevadorFormScreen({super.key, this.elevador});

  @override
  State<ElevadorFormScreen> createState() => _ElevadorFormScreenState();
}

class _ElevadorFormScreenState extends State<ElevadorFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _modeloController = TextEditingController();
  final _marcaController = TextEditingController();
  final _capacidadController = TextEditingController();
  final _direccionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.elevador != null) {
      _modeloController.text = widget.elevador!.modelo;
      _marcaController.text = widget.elevador!.marca;
      _capacidadController.text = widget.elevador!.capacidad.toString();
      _direccionController.text = widget.elevador!.direccion;
    }
  }

  @override
  void dispose() {
    _modeloController.dispose();
    _marcaController.dispose();
    _capacidadController.dispose();
    _direccionController.dispose();
    super.dispose();
  }

  Future<void> _saveElevador() async {
    if (_formKey.currentState!.validate()) {
      final capacidad = int.tryParse(_capacidadController.text.trim());
      if (capacidad == null || capacidad <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('La capacidad debe ser un número mayor a 0'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final elevador = Elevador(
        id: widget.elevador?.id,
        modelo: _modeloController.text.trim(),
        marca: _marcaController.text.trim(),
        capacidad: capacidad,
        direccion: _direccionController.text.trim(),
        clienteId: widget.elevador?.clienteId,
      );

      final service = context.read<ElevadorService>();
      final result = await service.createElevador(elevador);

      if (mounted) {
        if (result != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Elevador guardado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(service.error ?? 'Error al guardar elevador'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.elevador == null ? 'Nuevo Elevador' : 'Editar Elevador'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _marcaController,
                decoration: const InputDecoration(
                  labelText: 'Marca',
                  prefixIcon: Icon(Icons.branding_watermark),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese la marca';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _modeloController,
                decoration: const InputDecoration(
                  labelText: 'Modelo',
                  prefixIcon: Icon(Icons.info),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el modelo';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _capacidadController,
                decoration: const InputDecoration(
                  labelText: 'Capacidad (personas)',
                  prefixIcon: Icon(Icons.people),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese la capacidad';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'La capacidad debe ser un número mayor a 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _direccionController,
                decoration: const InputDecoration(
                  labelText: 'Dirección',
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese la dirección';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Consumer<ElevadorService>(
                builder: (context, service, child) {
                  return ElevatedButton(
                    onPressed: service.isLoading ? null : _saveElevador,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: service.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Guardar',
                            style: TextStyle(fontSize: 16),
                          ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

