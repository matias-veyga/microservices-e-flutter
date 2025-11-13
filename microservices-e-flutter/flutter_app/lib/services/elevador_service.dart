import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/elevador.dart';
import '../models/cliente.dart';
import 'api_config.dart';

class ElevadorService extends ChangeNotifier {
  List<Elevador> _elevadores = [];
  bool _isLoading = false;
  String? _error;

  List<Elevador> get elevadores => _elevadores;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAllElevadores() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.elevadorUrl}/all'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _elevadores = data.map((json) => Elevador.fromJson(json)).toList();
        _error = null;
      } else {
        _error = 'Error al cargar elevadores: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Error de conexión: $e';
      debugPrint('Error fetching elevadores: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Elevador?> createElevador(Elevador elevador) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.elevadorUrl}/create'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(elevador.toJson()),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final nuevoElevador = Elevador.fromJson(data);
        _elevadores.add(nuevoElevador);
        _error = null;
        _isLoading = false;
        notifyListeners();
        return nuevoElevador;
      } else {
        _error = 'Error al crear elevador: ${response.statusCode}';
        _isLoading = false;
        notifyListeners();
        return null;
      }
    } catch (e) {
      _error = 'Error de conexión: $e';
      _isLoading = false;
      notifyListeners();
      debugPrint('Error creating elevador: $e');
      return null;
    }
  }

  Future<Elevador?> getElevadorById(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.elevadorUrl}/search/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _error = null;
        _isLoading = false;
        notifyListeners();
        return Elevador.fromJson(data);
      } else {
        _error = 'Error al buscar elevador: ${response.statusCode}';
        _isLoading = false;
        notifyListeners();
        return null;
      }
    } catch (e) {
      _error = 'Error de conexión: $e';
      _isLoading = false;
      notifyListeners();
      debugPrint('Error fetching elevador: $e');
      return null;
    }
  }

  Future<List<Cliente>> getClientesByElevadorId(int elevadorId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.elevadorUrl}/search-cliente-by-elevador/$elevadorId'),
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

  Future<bool> asignarCliente(int elevadorId, int clienteId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.elevadorUrl}/$elevadorId/asignar-cliente/$clienteId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        _error = null;
        await fetchAllElevadores();
        return true;
      } else {
        _error = 'Error al asignar cliente: ${response.statusCode}';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error de conexión: $e';
      _isLoading = false;
      notifyListeners();
      debugPrint('Error asignando cliente: $e');
      return false;
    }
  }

  Future<bool> quitarCliente(int elevadorId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.elevadorUrl}/$elevadorId/quitar-cliente'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        _error = null;
        await fetchAllElevadores();
        return true;
      } else {
        _error = 'Error al quitar cliente: ${response.statusCode}';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error de conexión: $e';
      _isLoading = false;
      notifyListeners();
      debugPrint('Error quitando cliente: $e');
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

