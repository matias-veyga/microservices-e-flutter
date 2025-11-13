import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/cliente_service.dart';
import '../models/cliente.dart';
import 'cliente_form_screen.dart';
import 'cliente_detail_screen.dart';

class ClientesListScreen extends StatefulWidget {
  const ClientesListScreen({super.key});

  @override
  State<ClientesListScreen> createState() => _ClientesListScreenState();
}

class _ClientesListScreenState extends State<ClientesListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClienteService>().fetchAllClientes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ClienteService>().fetchAllClientes();
            },
          ),
        ],
      ),
      body: Consumer<ClienteService>(
        builder: (context, service, child) {
          if (service.isLoading && service.clientes.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (service.error != null && service.clientes.isEmpty) {
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
                      service.fetchAllClientes();
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (service.clientes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.people_outline,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No hay clientes registrados',
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
            onRefresh: () => service.fetchAllClientes(),
            child: ListView.builder(
              itemCount: service.clientes.length,
              padding: const EdgeInsets.all(8),
              itemBuilder: (context, index) {
                final cliente = service.clientes[index];
                return _buildClienteCard(context, cliente, service);
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
              builder: (context) => const ClienteFormScreen(),
            ),
          ).then((_) {
            context.read<ClienteService>().fetchAllClientes();
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildClienteCard(
    BuildContext context,
    Cliente cliente,
    ClienteService service,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.withOpacity(0.2),
          child: const Icon(Icons.person, color: Colors.blue),
        ),
        title: Text(
          '${cliente.nombre} ${cliente.apellido}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('DNI: ${cliente.dni}'),
            Text('Tel: ${cliente.telefono}'),
            if (cliente.elevadorId != null)
              Text(
                'Elevador ID: ${cliente.elevadorId}',
                style: TextStyle(
                  color: Colors.green[700],
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
              builder: (context) => ClienteDetailScreen(clienteId: cliente.id!),
            ),
          ).then((_) {
            service.fetchAllClientes();
          });
        },
      ),
    );
  }
}

