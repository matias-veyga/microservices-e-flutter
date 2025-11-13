package com.microservice.Elevador.entity;

import jakarta.persistence.*;
import lombok.*;

@Setter @Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "db_elevadores")
public class Elevador {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String modelo;
    private String marca;
    private Integer capacidad;
    private String direccion;
    private Long clienteId;
}
