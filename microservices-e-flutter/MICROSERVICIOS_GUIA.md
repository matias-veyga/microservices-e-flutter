# Sistema de Microservicios - Elevadores y Clientes

## Descripción del Proyecto

Este proyecto implementa un sistema de microservicios para la gestión de elevadores y clientes, utilizando Spring Boot, Spring Cloud, y una arquitectura de microservicios distribuida.

## Arquitectura del Sistema

### Microservicios Incluidos:

1. **microservice-eureka** (Puerto 8761) - Servidor de descubrimiento de servicios
2. **microservice-gateway** (Puerto 6768) - API Gateway para enrutamiento
3. **microservice-clientes-ele** (Puerto 8001) - Gestión de clientes
4. **microservice-elevadores-cli** (Puerto 8002) - Gestión de elevadores

## Instrucciones de Uso

### Prerrequisitos:
- Java 17 o superior
- Maven 3.6+
- MySQL 8.0+
- Navegador web moderno

### Configuración de la Base de Datos:

1. Crear base de datos MySQL llamada:
```sql
CREATE DATABASE microservicebd;
```


### Orden de Inicio:

1. **Iniciar Eureka Server:**
``
```
2. **Iniciar Microservicio de Clientes:**
```
```

3. **Iniciar Microservicio de Elevadores:**
``
```

4. **Iniciar API Gateway:**
```
```

### Acceso a las Vistas:

- **Gestión de Clientes:** http://localhost:8001/index.html
- **Gestión de Elevadores:** http://localhost:8002/index.html
- **Eureka Dashboard:** http://localhost:8761

## Endpoints de la API

### Microservicio Cliente (Puerto 8001):

```
POST   /api/cliente/create                    - Crear cliente
GET    /api/cliente/all                       - Obtener todos los clientes
GET    /api/cliente/search/{id}              - Buscar cliente por ID
GET    /api/cliente/search-by-elevador/{id}   - Buscar clientes por elevador
GET    /api/cliente/search-by-cliente/{id}    - Buscar cliente por ID
```

### Microservicio Elevador (Puerto 8002):

```
POST   /api/elevador/create                           - Crear elevador
GET    /api/elevador/all                             - Obtener todos los elevadores
GET    /api/elevador/search/{id}                     - Buscar elevador por ID
GET    /api/elevador/search-cliente-by-elevador/{id}  - Buscar clientes por elevador
```

## Funcionalidades de las Vistas

### Vista de Elevadores:
- ✅ **Crear elevador** con formulario completo
- ✅ **Ver lista** de todos los elevadores
- ✅ **Buscar elevadores** por modelo, marca, dirección
- ✅ **Ver detalles** de cada elevador
- ✅ **Ver clientes** asociados a cada elevador
- ✅ **Filtros** por estado y capacidad
- ✅ **Diseño responsivo** y moderno

### Vista de Clientes:
- ✅ **Crear cliente** con información completa
- ✅ **Ver lista** de todos los clientes
- ✅ **Buscar clientes** por nombre, DNI, teléfono
- ✅ **Ver detalles** completos del cliente
- ✅ **Estadísticas** en tiempo real
- ✅ **Filtros** por estado de elevador
- ✅ **Avatares** con iniciales personalizadas

## Tecnologías Utilizadas

- **Backend:** Spring Boot, Spring Cloud, Spring Data JPA
- **Base de Datos:** MySQL
- **Comunicación:** OpenFeign para comunicación entre microservicios
- **Frontend:** HTML5, CSS3, JavaScript, Bootstrap 5, Font Awesome
- **Servicio de Descubrimiento:** Netflix Eureka
- **API Gateway:** Spring Cloud Gateway
