# Arquitectura de Microservicios - Sistema de Gestión de Clientes y Ascensores

Este proyecto es un ejemplo de una arquitectura de microservicios desarrollada con Spring Boot y Spring Cloud. El sistema está diseñado para gestionar clientes y ascensores, utilizando un patrón de arquitectura distribuida.

## Descripción General

El proyecto consta de cuatro microservicios principales que trabajan juntos para proporcionar una solución completa:

1. **Servidor Eureka** - Descubrimiento de servicios
2. **API Gateway** - Punto de entrada único para todas las solicitudes
3. **Microservicio de Clientes** - Gestión de información de clientes
4. **Microservicio de Ascensores** - Gestión de ascensores y sus operaciones

## Estructura del Proyecto

### 1. microservice-eureka

**Propósito**: Servidor de descubrimiento de servicios basado en Netflix Eureka.

**Funcionalidades principales**:
- Registro y descubrimiento de servicios
- Balanceo de carga del lado del cliente
- Monitoreo del estado de los servicios

**Dependencias principales**:
- `spring-cloud-starter-netflix-eureka-server`: Servidor de descubrimiento de servicios
- `spring-boot-starter-actuator`: Monitoreo y gestión de la aplicación
- `spring-cloud-starter-config`: Integración con Spring Cloud Config

### 2. microservice-gateway

**Propósito**: API Gateway que actúa como punto de entrada único para todas las solicitudes.

**Funcionalidades principales**:
- Enrutamiento de solicitudes a los microservicios correspondientes
- Balanceo de carga
- Cross-Origin Resource Sharing (CORS)
- Seguridad centralizada

**Dependencias principales**:
- `spring-cloud-starter-gateway`: Implementación del API Gateway
- `spring-cloud-starter-netflix-eureka-client`: Integración con Eureka
- `spring-boot-starter-actuator`: Monitoreo y gestión

### 3. microservice-clientes-ele

**Propósito**: Gestiona la información de los clientes del sistema.

**Funcionalidades principales**:
- CRUD de clientes
- Almacenamiento persistente de datos de clientes
- Integración con base de datos MySQL

**Dependencias principales**:
- `spring-boot-starter-data-jpa`: Persistencia de datos
- `spring-boot-starter-web`: Desarrollo de aplicaciones web
- `mysql-connector-j`: Conector para MySQL
- `spring-cloud-starter-netflix-eureka-client`: Registro en Eureka

### 4. microservice-elevadores-cli

**Propósito**: Gestiona la información y operaciones relacionadas con los ascensores.

**Funcionalidades principales**:
- Gestión de ascensores
- Operaciones específicas del dominio de ascensores
- Comunicación con otros microservicios mediante Feign Client

**Dependencias principales**:
- `spring-boot-starter-data-jpa`: Persistencia de datos
- `spring-boot-starter-web`: Desarrollo de aplicaciones web
- `spring-cloud-starter-openfeign`: Cliente HTTP declarativo
- `mysql-connector-j`: Conector para MySQL
- `spring-cloud-starter-netflix-eureka-client`: Registro en Eureka

## Tecnologías Utilizadas

- **Java 17**: Lenguaje de programación principal
- **Spring Boot 3.2.4**: Framework para el desarrollo de aplicaciones Java
- **Spring Cloud 2023.0.0**: Herramientas para sistemas distribuidos
- **Spring Cloud Netflix Eureka**: Descubrimiento de servicios
- **Spring Cloud Gateway**: API Gateway
- **Spring Data JPA**: Acceso a datos
- **MySQL**: Base de datos relacional
- **Lombok**: Reducción de código boilerplate
- **Maven**: Gestión de dependencias

## Diagrama de Arquitectura

```
+----------------+     +------------------+     +---------------------+
|                |     |                  |     |                     |
|   Cliente      |<--->|   API Gateway    |<--->|  microservice-      |
|   (Frontend)   |     |                  |     |  clientes-ele       |
|                |     |                  |     |                     |
+----------------+     +------------------+     +---------------------+
                                                    ^            |
                                                    |            |
                                                    v            v
+----------------+     +------------------+     +---------------------+
|                |     |                  |     |                     |
|   Eureka       |<--->|  microservice-   |<--->|  microservice-      |
|   Server       |     |  elevadores-cli  |     |  clientes-ele       |
|                |     |                  |     |                     |
+----------------+     +------------------+     +---------------------+
```

## Requisitos del Sistema

- Java 17 o superior
- Maven 3.6 o superior
- MySQL 8.0 o superior
- Consola de comandos (CLI) para ejecutar los servicios

## Configuración

1. Clonar el repositorio
2. Configurar las credenciales de la base de datos en los archivos de configuración de cada microservicio
3. Asegurarse de que el servidor Eureka esté en ejecución antes que los demás servicios
4. Iniciar los servicios en el siguiente orden:
   1. microservice-eureka
   2. microservice-gateway
   3. microservice-clientes-ele
   4. microservice-elevadores-cli




