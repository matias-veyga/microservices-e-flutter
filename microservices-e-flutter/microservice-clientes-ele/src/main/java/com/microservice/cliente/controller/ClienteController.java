package com.microservice.cliente.controller;

import com.microservice.cliente.entities.Cliente;
import com.microservice.cliente.service.IClienteService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/cliente")
public class ClienteController {

    @Autowired
    private IClienteService clienteService;

    @PostMapping("/create")
    public ResponseEntity<?> saveCliente(@RequestBody Cliente cliente){
        try {
            Cliente clienteGuardado = clienteService.save(cliente);
            return ResponseEntity.status(HttpStatus.CREATED).body(clienteGuardado);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Error al crear cliente: " + e.getMessage());
        }
    }

    @GetMapping("/all")
    public ResponseEntity<?> findById(){
        return ResponseEntity.ok(clienteService.findAll());
    }

    @GetMapping("/search/{id}")
    public ResponseEntity<?> findById(@PathVariable Long id){
        return ResponseEntity.ok(clienteService.findById(id));
    }

    @GetMapping("/search-by-elevador/{elevadorId}")
    public ResponseEntity<?> findByIdElevador(@PathVariable Long elevadorId){
        return ResponseEntity.ok(clienteService.findByElevadorId(elevadorId));
    }

    @GetMapping("/search-by-cliente/{clienteId}")
    public ResponseEntity<?> findByIdCliente(@PathVariable Long clienteId){
        return ResponseEntity.ok(clienteService.findByClienteId(clienteId));
    }
}
