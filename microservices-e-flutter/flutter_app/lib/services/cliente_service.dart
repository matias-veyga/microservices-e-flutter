import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/cliente.dart';
import 'api_config.dart';

class ClienteService extends ChangeNotifier {
  List<Cliente> _clientes = [];
  bool _isLoading = false;
  String? _error;

  List<Cliente> get clientes => _clientes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAllClientes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.clienteUrl}/all'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _clientes = data.map((json) => Cliente.fromJson(json)).toList();
        _error = null;
      } else {
        _error = 'Error al cargar clientes: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Error de conexión: $e';
      debugPrint('Error fetching clientes: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Cliente?> createCliente(Cliente cliente) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.clienteUrl}/create'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(cliente.toJson()),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final nuevoCliente = Cliente.fromJson(data);
        _clientes.add(nuevoCliente);
        _error = null;
        _isLoading = false;
        notifyListeners();
        return nuevoCliente;
      } else {
        _error = 'Error al crear cliente: ${response.statusCode}';
        _isLoading = false;
        notifyListeners();
        return null;
      }
    } catch (e) {
      _error = 'Error de conexión: $e';
      _isLoading = false;
      notifyListeners();
      debugPrint('Error creating cliente: $e');
      return null;
    }
  }

  Future<Cliente?> getClienteById(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.clienteUrl}/search/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _error = null;
        _isLoading = false;
        notifyListeners();
        return Cliente.fromJson(data);
      } else {
        _error = 'Error al buscar cliente: ${response.statusCode}';
        _isLoading = false;
        notifyListeners();
        return null;
      }
    } catch (e) {
      _error = 'Error de conexión: $e';
      _isLoading = false;
      notifyListeners();
      debugPrint('Error fetching cliente: $e');
      return null;
    }
  }

  Future<List<Cliente>> getClientesByElevadorId(int elevadorId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.clienteUrl}/search-by-elevador/$elevadorId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _error = null;
        _isLoading = false;
        notifyListeners();
        return data.map((json) => Cliente.fromJson(json)).toList();
      } else {
        _error = 'Error al buscar clientes: ${response.statusCode}';
        _isLoading = false;
        notifyListeners();
        return [];
      }
    } catch (e) {
      _error = 'Error de conexión: $e';
      _isLoading = false;
      notifyListeners();
      debugPrint('Error fetching clientes by elevador: $e');
      return [];
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

