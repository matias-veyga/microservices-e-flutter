import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/elevador_service.dart';
import '../models/elevador.dart';
import 'elevador_form_screen.dart';
import 'elevador_detail_screen.dart';

class ElevadoresListScreen extends StatefulWidget {
  const ElevadoresListScreen({super.key});

  @override
  State<ElevadoresListScreen> createState() => _ElevadoresListScreenState();
}

class _ElevadoresListScreenState extends State<ElevadoresListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ElevadorService>().fetchAllElevadores();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Elevadores'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ElevadorService>().fetchAllElevadores();
            },
          ),
        ],
      ),
      body: Consumer<ElevadorService>(
        builder: (context, service, child) {
          if (service.isLoading && service.elevadores.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (service.error != null && service.elevadores.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    service.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      service.clearError();
                      service.fetchAllElevadores();
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (service.elevadores.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.elevator_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No hay elevadores registrados',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Toca el botón + para agregar uno',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => service.fetchAllElevadores(),
            child: ListView.builder(
              itemCount: service.elevadores.length,
              padding: const EdgeInsets.all(8),
              itemBuilder: (context, index) {
                final elevador = service.elevadores[index];
                return _buildElevadorCard(context, elevador, service);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ElevadorFormScreen(),
            ),
          ).then((_) {
            context.read<ElevadorService>().fetchAllElevadores();
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildElevadorCard(
    BuildContext context,
    Elevador elevador,
    ElevadorService service,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.withOpacity(0.2),
          child: const Icon(Icons.elevator, color: Colors.green),
        ),
        title: Text(
          '${elevador.marca} ${elevador.modelo}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Capacidad: ${elevador.capacidad} personas'),
            Text('Dirección: ${elevador.direccion}'),
            if (elevador.clienteId != null)
              Text(
                'Cliente ID: ${elevador.clienteId}',
                style: TextStyle(
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ElevadorDetailScreen(elevadorId: elevador.id!),
            ),
          ).then((_) {
            service.fetchAllElevadores();
          });
        },
      ),
    );
  }
}

