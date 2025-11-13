import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/elevador_service.dart';
import '../services/cliente_service.dart';
import '../models/elevador.dart';
import '../models/cliente.dart';

class ElevadorDetailScreen extends StatefulWidget {
  final int elevadorId;

  const ElevadorDetailScreen({super.key, required this.elevadorId});

  @override
  State<ElevadorDetailScreen> createState() => _ElevadorDetailScreenState();
}

class _ElevadorDetailScreenState extends State<ElevadorDetailScreen> {
  Elevador? _elevador;
  List<Cliente> _clientesAsignados = [];
  bool _isLoadingClientes = false;

  @override
  void initState() {
    super.initState();
    _loadElevador();
  }

  Future<void> _loadElevador() async {
    final service = context.read<ElevadorService>();
    final elevador = await service.getElevadorById(widget.elevadorId);
    if (mounted) {
      setState(() {
        _elevador = elevador;
      });
      if (elevador != null) {
        _loadClientesAsignados();
      }
    }
  }

  Future<void> _loadClientesAsignados() async {
    setState(() {
      _isLoadingClientes = true;
    });
    final service = context.read<ElevadorService>();
    final clientes = await service.getClientesByElevadorId(widget.elevadorId);
    if (mounted) {
      setState(() {
        _clientesAsignados = clientes;
        _isLoadingClientes = false;
      });
    }
  }

  Future<void> _asignarCliente() async {
    final clienteService = context.read<ClienteService>();
    await clienteService.fetchAllClientes();

    if (!mounted) return;

    final clientesDisponibles = clienteService.clientes
        .where((c) => c.elevadorId == null || c.elevadorId != widget.elevadorId)
        .toList();

    if (clientesDisponibles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay clientes disponibles para asignar'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final clienteSeleccionado = await showDialog<Cliente>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar Cliente'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: clientesDisponibles.length,
            itemBuilder: (context, index) {
              final cliente = clientesDisponibles[index];
              return ListTile(
                title: Text('${cliente.nombre} ${cliente.apellido}'),
                subtitle: Text('DNI: ${cliente.dni}'),
                onTap: () => Navigator.pop(context, cliente),
              );
            },
          ),
        ),
      ),
    );

    if (clienteSeleccionado != null && mounted) {
      final elevadorService = context.read<ElevadorService>();
      final success = await elevadorService.asignarCliente(
        widget.elevadorId,
        clienteSeleccionado.id!,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cliente asignado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          _loadElevador();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(elevadorService.error ?? 'Error al asignar cliente'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _quitarCliente() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar'),
        content: const Text('¿Desea quitar el cliente asignado a este elevador?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Quitar'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final service = context.read<ElevadorService>();
      final success = await service.quitarCliente(widget.elevadorId);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cliente removido exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          _loadElevador();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(service.error ?? 'Error al quitar cliente'),
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
        title: const Text('Detalle del Elevador'),
      ),
      body: _elevador == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.green.withOpacity(0.2),
                                child: const Icon(
                                  Icons.elevator,
                                  size: 30,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${_elevador!.marca} ${_elevador!.modelo}',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'ID: ${_elevador!.id}',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    'Información del Elevador',
                    [
                      _buildInfoRow('Marca', _elevador!.marca),
                      _buildInfoRow('Modelo', _elevador!.modelo),
                      _buildInfoRow('Capacidad', '${_elevador!.capacidad} personas'),
                      _buildInfoRow('Dirección', _elevador!.direccion),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Cliente Asignado',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (_elevador!.clienteId != null)
                                ElevatedButton.icon(
                                  onPressed: _quitarCliente,
                                  icon: const Icon(Icons.remove_circle_outline),
                                  label: const Text('Quitar'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                )
                              else
                                ElevatedButton.icon(
                                  onPressed: _asignarCliente,
                                  icon: const Icon(Icons.add_circle_outline),
                                  label: const Text('Asignar'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (_isLoadingClientes)
                            const Center(child: CircularProgressIndicator())
                          else if (_elevador!.clienteId == null)
                            const Text(
                              'No hay cliente asignado',
                              style: TextStyle(color: Colors.grey),
                            )
                          else if (_clientesAsignados.isEmpty)
                            Text(
                              'Cliente ID: ${_elevador!.clienteId}',
                              style: const TextStyle(color: Colors.grey),
                            )
                          else
                            ..._clientesAsignados.map((cliente) => Card(
                                  margin: const EdgeInsets.only(top: 8),
                                  color: Colors.blue.withOpacity(0.1),
                                  child: ListTile(
                                    leading: const Icon(Icons.person, color: Colors.blue),
                                    title: Text(
                                      '${cliente.nombre} ${cliente.apellido}',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text('DNI: ${cliente.dni}'),
                                  ),
                                )),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

