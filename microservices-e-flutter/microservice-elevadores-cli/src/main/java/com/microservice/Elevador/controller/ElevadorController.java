package com.microservice.Elevador.controller;

import com.microservice.Elevador.entity.Elevador;
import com.microservice.Elevador.service.IElevadorService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/elevador")
public class ElevadorController {

    @Autowired
    private IElevadorService elevadorService;

    @PostMapping("/create")
    public ResponseEntity<?> saveElevador(@RequestBody Elevador elevador){
        try {
            Elevador elevadorGuardado = elevadorService.save(elevador);
            return ResponseEntity.status(HttpStatus.CREATED).body(elevadorGuardado);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Error al crear elevador: " + e.getMessage());
        }
    }

    @GetMapping("/all")
    public ResponseEntity<?> findAll(){
        return ResponseEntity.ok(elevadorService.findAll());
    }

    @GetMapping("/search/{id}")
    public ResponseEntity<?> findById(@PathVariable Long id){
        return ResponseEntity.ok(elevadorService.findById(id));
    }

    @GetMapping("/search-cliente-by-elevador/{elevadorId}")
    public ResponseEntity<?> findClientesByElevadorId(@PathVariable Long elevadorId){
        return ResponseEntity.ok(elevadorService.findClientesByElevadorId(elevadorId));
    }

    @PutMapping("/{elevadorId}/quitar-cliente")
    public ResponseEntity<?> quitarCliente(@PathVariable("elevadorId") Long elevadorId){
        try {
            Elevador elevadorActualizado = elevadorService.asignarCliente(elevadorId, null);
            return ResponseEntity.ok(elevadorActualizado);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Error al quitar cliente: " + e.getMessage());
        }
    }

    @PutMapping("/{elevadorId}/asignar-cliente/{clienteId}")
    public ResponseEntity<?> asignarCliente(@PathVariable Long elevadorId, @PathVariable Long clienteId){
        try {
            Elevador elevadorActualizado = elevadorService.asignarCliente(elevadorId, clienteId);
            return ResponseEntity.ok(elevadorActualizado);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Error al asignar cliente: " + e.getMessage());
        }
    }
}
