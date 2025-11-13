package com.microservice.Elevador.controller.sto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class ClienteDTO {
    private String nombre;
    private String apellido;
    private String DNI;
    private String telefono;
    private String direccion;
    private Long elevadorId;
}
