# Aplicación Móvil Flutter - Gestión de Elevadores y Clientes

Aplicación móvil desarrollada en Flutter y Dart para gestionar clientes y elevadores, conectada al backend de microservicios a través del API Gateway.

## Características

- ✅ Gestión completa de clientes (crear, listar, ver detalles)
- ✅ Gestión completa de elevadores (crear, listar, ver detalles)
- ✅ Asignación de clientes a elevadores
- ✅ Interfaz de usuario moderna y responsive
- ✅ Manejo de errores y estados de carga
- ✅ Integración con API Gateway (puerto 6768)

## Funcionamiento del Proyecto

### Arquitectura del Sistema

El proyecto sigue una arquitectura de microservicios con los siguientes componentes:

```
┌─────────────────┐
│   Flutter App   │
│   (Móvil)       │
└────────┬────────┘
         │ HTTP Requests
         │ (Puerto 6768)
         ▼
┌─────────────────┐
│  API Gateway    │
│  (Puerto 6768)  │
└────────┬────────┘
         │
         ├─────────────────┬─────────────────┐
         │                 │                 │
         ▼                 ▼                 ▼
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│   Eureka     │  │  Cliente     │  │  Elevador    │
│   Server     │  │  Service     │  │  Service    │
│ (Puerto 8761)│  │ (Puerto 8001)│  │ (Puerto 8002)│
└──────────────┘  └──────┬───────┘  └──────┬───────┘
         │               │                 │
         │               ▼                 ▼
         │        ┌──────────────┐  ┌──────────────┐
         │        │    MySQL     │  │    MySQL     │
         │        │  Database    │  │  Database   │
         │        │ (Puerto 3306)│  │ (Puerto 3306)│
         │        └──────────────┘  └──────────────┘
         │
         └─── Service Discovery ───┘
```

### Flujo de Comunicación

1. **Flutter App → API Gateway**
   - La aplicación Flutter realiza peticiones HTTP al API Gateway en el puerto 6768
   - Todas las peticiones pasan a través del gateway, que actúa como punto de entrada único
   - El gateway maneja CORS y enruta las peticiones a los microservicios correspondientes

2. **API Gateway → Eureka Server**
   - El gateway se registra en Eureka Server (puerto 8761) para descubrir servicios
   - Utiliza el balanceador de carga (`lb://`) para distribuir peticiones entre instancias

3. **API Gateway → Microservicios**
   - **Rutas de Cliente**: `/api/cliente/**` → `msvc-cliente` (puerto 8001)
   - **Rutas de Elevador**: `/api/elevador/**` → `msvc-elevador` (puerto 8002)
   - El gateway enruta automáticamente según el path de la petición

4. **Microservicios → Eureka Server**
   - Ambos microservicios (cliente y elevador) se registran en Eureka
   - Eureka mantiene un registro de todos los servicios disponibles

5. **Microservicios → MySQL Database**
   - Cada microservicio se conecta a la base de datos MySQL (puerto 3306)
   - Ambos comparten la misma base de datos `microservicebd`
   - Utilizan JPA/Hibernate para el mapeo objeto-relacional

### Conexión de Flutter App con los Microservicios

#### 1. **Flutter App ↔ API Gateway**

**Archivo**: `lib/services/api_config.dart`

```dart
static const String baseUrl = 'http://192.168.2.3:6768';
```

- La app Flutter se conecta directamente al API Gateway
- El gateway escucha en todas las interfaces (`0.0.0.0:6768`) para permitir conexiones desde dispositivos móviles
- Todas las peticiones HTTP se realizan a través del gateway

**Ejemplo de petición**:
```dart
// Flutter App
GET http://192.168.2.3:6768/api/cliente/all

// API Gateway recibe y enruta a:
GET http://msvc-cliente/api/cliente/all
```

#### 2. **API Gateway ↔ Eureka Server**

**Archivo**: `microservice-gateway/src/main/resources/application.yml`

```yaml
eureka:
  client:
    service-url:
      defaultZone: http://localhost:8761/eureka
```

- El gateway se registra en Eureka para descubrir servicios
- Utiliza `lb://msvc-cliente` y `lb://msvc-elevador` para balanceo de carga
- Eureka proporciona el descubrimiento de servicios dinámico

#### 3. **API Gateway ↔ Microservicio Cliente**

**Archivo**: `microservice-gateway/src/main/resources/application.yml`

```yaml
routes:
  - id: cliente-service
    uri: lb://msvc-cliente
    predicates:
      - Path=/api/cliente/**
```

- Cualquier petición a `/api/cliente/**` se enruta al microservicio de clientes
- El gateway usa el nombre del servicio registrado en Eureka (`msvc-cliente`)
- El microservicio corre en el puerto 8001

**Flujo completo**:
```
Flutter App → GET /api/cliente/all
    ↓
API Gateway → Enruta a msvc-cliente
    ↓
Eureka → Resuelve msvc-cliente → localhost:8001
    ↓
Cliente Service → Consulta MySQL
    ↓
Cliente Service → Retorna JSON
    ↓
API Gateway → Retorna respuesta a Flutter App
```

#### 4. **API Gateway ↔ Microservicio Elevador**

**Archivo**: `microservice-gateway/src/main/resources/application.yml`

```yaml
routes:
  - id: elevador-service
    uri: lb://msvc-elevador
    predicates:
      - Path=/api/elevador/**
```

- Cualquier petición a `/api/elevador/**` se enruta al microservicio de elevadores
- El microservicio corre en el puerto 8002
- Sigue el mismo flujo que el microservicio de clientes

#### 5. **Microservicios ↔ MySQL Database**

**Archivo**: `microservice-clientes-ele/src/main/resources/application.yml`
**Archivo**: `microservice-elevadores-cli/src/main/resources/application.yml`

```yaml
datasource:
  url: jdbc:mysql://localhost:3306/microservicebd
  username: root
  password: 
```

- Ambos microservicios se conectan a la misma base de datos MySQL
- Utilizan JPA/Hibernate para persistencia
- Las tablas se crean automáticamente con `ddl-auto: update`

## Requisitos Previos

- Flutter SDK 3.0.0 o superior
- Dart SDK 3.0.0 o superior
- Backend de microservicios ejecutándose:
  - Eureka Server (puerto 8761)
  - API Gateway (puerto 6768)
  - Microservicio de Clientes (puerto 8001)
  - Microservicio de Elevadores (puerto 8002)

## ¿Por qué necesitan estar activos los microservicios?

La aplicación Flutter **depende completamente** de los microservicios backend para funcionar correctamente. Aunque la app Flutter se conecta directamente al API Gateway, el gateway actúa únicamente como un intermediario que enruta las peticiones a los microservicios correspondientes. Sin los microservicios activos, la aplicación no podrá realizar ninguna operación.

### Dependencia del Microservicio Cliente (`microservice-clientes-ele`)

El microservicio de clientes es **esencial** para todas las funcionalidades relacionadas con clientes en la aplicación Flutter:

- **Sin este microservicio activo**, las siguientes funcionalidades **NO funcionarán**:
  - ❌ Listar clientes (`GET /api/cliente/all`)
  - ❌ Crear nuevos clientes (`POST /api/cliente/create`)
  - ❌ Ver detalles de un cliente (`GET /api/cliente/search/{id}`)
  - ❌ Buscar clientes por elevador (`GET /api/cliente/search-by-elevador/{id}`)

**¿Qué sucede si no está activo?**
- El API Gateway recibirá las peticiones pero no podrá enrutarlas al microservicio
- Eureka no encontrará el servicio `msvc-cliente` registrado
- La aplicación Flutter recibirá errores 503 (Service Unavailable) o 404 (Not Found)
- Todas las pantallas relacionadas con clientes mostrarán errores de conexión

### Dependencia del Microservicio Elevador (`microservice-elevadores-cli`)

El microservicio de elevadores es **esencial** para todas las funcionalidades relacionadas con elevadores en la aplicación Flutter:

- **Sin este microservicio activo**, las siguientes funcionalidades **NO funcionarán**:
  - ❌ Listar elevadores (`GET /api/elevador/all`)
  - ❌ Crear nuevos elevadores (`POST /api/elevador/create`)
  - ❌ Ver detalles de un elevador (`GET /api/elevador/search/{id}`)
  - ❌ Buscar clientes asignados a un elevador (`GET /api/elevador/search-cliente-by-elevador/{id}`)
  - ❌ Asignar cliente a elevador (`PUT /api/elevador/{id}/asignar-cliente/{clienteId}`)
  - ❌ Quitar cliente de elevador (`PUT /api/elevador/{id}/quitar-cliente`)

**¿Qué sucede si no está activo?**
- El API Gateway recibirá las peticiones pero no podrá enrutarlas al microservicio
- Eureka no encontrará el servicio `msvc-elevador` registrado
- La aplicación Flutter recibirá errores 503 (Service Unavailable) o 404 (Not Found)
- Todas las pantallas relacionadas con elevadores mostrarán errores de conexión

### Flujo de Dependencia

```
Flutter App
    ↓ (requiere)
API Gateway
    ↓ (requiere)
Eureka Server (para descubrir servicios)
    ↓ (requiere)
Microservicio Cliente ──┐
    ↓                    │ (ambos deben estar activos)
Microservicio Elevador ─┘
    ↓
MySQL Database
```

### Resumen

**La aplicación Flutter NO puede funcionar sin los microservicios activos** porque:

1. **No hay lógica de negocio en Flutter**: La app Flutter es únicamente una interfaz de usuario (UI) que consume APIs REST
2. **No hay base de datos local**: Todos los datos se almacenan en MySQL y se acceden a través de los microservicios
3. **El API Gateway solo enruta**: El gateway no procesa datos, solo redirige peticiones a los microservicios correspondientes
4. **Service Discovery requiere servicios registrados**: Eureka necesita que los microservicios estén activos y registrados para que el gateway pueda encontrarlos

**Orden de inicio obligatorio**:
1. ✅ MySQL Database (puerto 3306)
2. ✅ Eureka Server (puerto 8761)
3. ✅ Microservicio Cliente (puerto 8001) - **DEBE estar activo**
4. ✅ Microservicio Elevador (puerto 8002) - **DEBE estar activo**
5. ✅ API Gateway (puerto 6768)
6. ✅ Flutter App

## Configuración

### 1. Instalar dependencias

```bash
cd flutter_app
flutter pub get
```

### 2. Configurar URL del API Gateway

Edita el archivo `lib/services/api_config.dart` y ajusta la URL según tu entorno:

```dart
// Para emulador Android
static const String baseUrl = 'http://10.0.2.2:6768';

// Para dispositivo físico (reemplaza con tu IP local)
static const String baseUrl = 'http://192.168.1.100:6768';

// Para iOS Simulator
static const String baseUrl = 'http://localhost:6768';
```

### 3. Ejecutar la aplicación

```bash
flutter run
```

## Estructura del Proyecto

```
flutter_app/
├── lib/
│   ├── main.dart                 # Punto de entrada
│   ├── models/                   # Modelos de datos
│   │   ├── cliente.dart
│   │   └── elevador.dart
│   ├── services/                 # Servicios API
│   │   ├── api_config.dart
│   │   ├── cliente_service.dart
│   │   └── elevador_service.dart
│   └── screens/                  # Pantallas
│       ├── home_screen.dart
│       ├── clientes_list_screen.dart
│       ├── cliente_form_screen.dart
│       ├── cliente_detail_screen.dart
│       ├── elevadores_list_screen.dart
│       ├── elevador_form_screen.dart
│       └── elevador_detail_screen.dart
├── pubspec.yaml                  # Dependencias
└── README.md
```

## Explicación de los Servicios

Los servicios son clases que manejan la comunicación entre la aplicación Flutter y el backend a través del API Gateway. Actúan como una capa de abstracción que simplifica las operaciones HTTP y gestiona el estado de la aplicación.

### `api_config.dart` - Configuración de la API

**Propósito**: Centraliza la configuración de las URLs base para todas las peticiones HTTP.

**¿Qué hace?**
- Define la URL base del API Gateway (`baseUrl`)
- Define los paths base para los endpoints de cliente y elevador
- Proporciona getters que construyen las URLs completas

**Código principal**:
```dart
static const String baseUrl = 'http://192.168.2.3:6768';
static const String clienteBasePath = '/api/cliente';
static const String elevadorBasePath = '/api/elevador';

static String get clienteUrl => '$baseUrl$clienteBasePath';
static String get elevadorUrl => '$baseUrl$elevadorBasePath';
```

**Ventajas**:
- ✅ **Centralización**: Si necesitas cambiar la URL del servidor, solo modificas un archivo
- ✅ **Mantenibilidad**: Facilita la configuración para diferentes entornos (desarrollo, producción)
- ✅ **Reutilización**: Todas las pantallas y servicios usan las mismas URLs

**Ejemplo de uso**:
```dart
// En lugar de escribir:
'http://192.168.2.3:6768/api/cliente/all'

// Simplemente usas:
'${ApiConfig.clienteUrl}/all'
```

**⚠️ Importante**: Debes cambiar `baseUrl` según tu entorno:
- Emulador Android: `http://10.0.2.2:6768`
- Dispositivo físico: `http://TU_IP_LOCAL:6768`
- iOS Simulator: `http://localhost:6768`

---

### `cliente_service.dart` - Servicio de Gestión de Clientes

**Propósito**: Maneja todas las operaciones relacionadas con clientes (CRUD y búsquedas).

**¿Qué hace?**
- Extiende `ChangeNotifier` para notificar cambios a la UI (patrón Provider)
- Gestiona el estado de carga (`isLoading`) y errores (`error`)
- Mantiene una lista en memoria de todos los clientes (`_clientes`)
- Realiza peticiones HTTP al API Gateway para operaciones con clientes

**Métodos principales**:

1. **`fetchAllClientes()`**
   - **Acción**: Obtiene todos los clientes del servidor
   - **Endpoint**: `GET /api/cliente/all`
   - **Retorna**: `Future<void>` (actualiza la lista interna `_clientes`)
   - **Uso**: Se llama cuando se abre la pantalla de lista de clientes

2. **`createCliente(Cliente cliente)`**
   - **Acción**: Crea un nuevo cliente en el servidor
   - **Endpoint**: `POST /api/cliente/create`
   - **Retorna**: `Future<Cliente?>` (el cliente creado o `null` si hay error)
   - **Uso**: Se llama desde el formulario de creación de clientes

3. **`getClienteById(int id)`**
   - **Acción**: Obtiene un cliente específico por su ID
   - **Endpoint**: `GET /api/cliente/search/{id}`
   - **Retorna**: `Future<Cliente?>` (el cliente encontrado o `null`)
   - **Uso**: Se llama para mostrar los detalles de un cliente

4. **`getClientesByElevadorId(int elevadorId)`**
   - **Acción**: Obtiene todos los clientes asignados a un elevador específico
   - **Endpoint**: `GET /api/cliente/search-by-elevador/{elevadorId}`
   - **Retorna**: `Future<List<Cliente>>` (lista de clientes)
   - **Uso**: Se llama para ver qué clientes están asignados a un elevador

5. **`clearError()`**
   - **Acción**: Limpia el mensaje de error actual
   - **Uso**: Se llama cuando el usuario descarta un error

**Gestión de estado**:
- `_isLoading`: Indica si hay una petición HTTP en curso
- `_error`: Almacena el mensaje de error si algo falla
- `_clientes`: Lista en memoria de todos los clientes cargados

**Notificación de cambios**:
- Cada vez que se actualiza el estado, llama a `notifyListeners()`
- Esto notifica a todos los widgets que están escuchando (usando `Consumer<ClienteService>`)
- La UI se actualiza automáticamente cuando cambian los datos

**Ejemplo de flujo**:
```
Usuario presiona "Listar Clientes"
    ↓
Pantalla llama: clienteService.fetchAllClientes()
    ↓
ClienteService hace: GET http://192.168.2.3:6768/api/cliente/all
    ↓
API Gateway enruta a: Microservicio Cliente
    ↓
Microservicio consulta MySQL y retorna JSON
    ↓
ClienteService convierte JSON a objetos Cliente
    ↓
ClienteService actualiza _clientes y llama notifyListeners()
    ↓
Pantalla se actualiza automáticamente mostrando los clientes
```

---

### `elevador_service.dart` - Servicio de Gestión de Elevadores

**Propósito**: Maneja todas las operaciones relacionadas con elevadores (CRUD, búsquedas y asignaciones).

**¿Qué hace?**
- Similar a `ClienteService`, pero para elevadores
- Extiende `ChangeNotifier` para notificar cambios a la UI
- Gestiona el estado de carga y errores
- Mantiene una lista en memoria de todos los elevadores
- Realiza peticiones HTTP al API Gateway para operaciones con elevadores

**Métodos principales**:

1. **`fetchAllElevadores()`**
   - **Acción**: Obtiene todos los elevadores del servidor
   - **Endpoint**: `GET /api/elevador/all`
   - **Retorna**: `Future<void>` (actualiza la lista interna `_elevadores`)
   - **Uso**: Se llama cuando se abre la pantalla de lista de elevadores

2. **`createElevador(Elevador elevador)`**
   - **Acción**: Crea un nuevo elevador en el servidor
   - **Endpoint**: `POST /api/elevador/create`
   - **Retorna**: `Future<Elevador?>` (el elevador creado o `null` si hay error)
   - **Uso**: Se llama desde el formulario de creación de elevadores

3. **`getElevadorById(int id)`**
   - **Acción**: Obtiene un elevador específico por su ID
   - **Endpoint**: `GET /api/elevador/search/{id}`
   - **Retorna**: `Future<Elevador?>` (el elevador encontrado o `null`)
   - **Uso**: Se llama para mostrar los detalles de un elevador

4. **`getClientesByElevadorId(int elevadorId)`**
   - **Acción**: Obtiene todos los clientes asignados a un elevador específico
   - **Endpoint**: `GET /api/elevador/search-cliente-by-elevador/{elevadorId}`
   - **Retorna**: `Future<List<Cliente>>` (lista de clientes asignados)
   - **Uso**: Se llama para ver qué clientes están asignados a un elevador

5. **`asignarCliente(int elevadorId, int clienteId)`**
   - **Acción**: Asigna un cliente a un elevador
   - **Endpoint**: `PUT /api/elevador/{elevadorId}/asignar-cliente/{clienteId}`
   - **Retorna**: `Future<bool>` (`true` si se asignó correctamente)
   - **Uso**: Se llama desde la pantalla de detalles del elevador para asignar un cliente

6. **`quitarCliente(int elevadorId)`**
   - **Acción**: Quita la asignación de un cliente de un elevador
   - **Endpoint**: `PUT /api/elevador/{elevadorId}/quitar-cliente`
   - **Retorna**: `Future<bool>` (`true` si se quitó correctamente)
   - **Uso**: Se llama desde la pantalla de detalles del elevador para quitar un cliente

7. **`clearError()`**
   - **Acción**: Limpia el mensaje de error actual
   - **Uso**: Se llama cuando el usuario descarta un error

**Gestión de estado**:
- `_isLoading`: Indica si hay una petición HTTP en curso
- `_error`: Almacena el mensaje de error si algo falla
- `_elevadores`: Lista en memoria de todos los elevadores cargados

**Características especiales**:
- Después de asignar o quitar un cliente, automáticamente recarga la lista de elevadores (`fetchAllElevadores()`) para reflejar los cambios
- Maneja la conversión entre JSON (del servidor) y objetos Dart (`Elevador`, `Cliente`)

**Ejemplo de flujo de asignación**:
```
Usuario presiona "Asignar Cliente" en un elevador
    ↓
Pantalla llama: elevadorService.asignarCliente(elevadorId, clienteId)
    ↓
ElevadorService hace: PUT /api/elevador/{id}/asignar-cliente/{clienteId}
    ↓
API Gateway enruta a: Microservicio Elevador
    ↓
Microservicio actualiza la relación en MySQL
    ↓
ElevadorService recarga la lista: fetchAllElevadores()
    ↓
ElevadorService llama notifyListeners()
    ↓
Pantalla se actualiza mostrando el cliente asignado
```

---

### Resumen de los Servicios

| Servicio | Responsabilidad | Patrón Utilizado |
|----------|----------------|------------------|
| **`api_config.dart`** | Configuración centralizada de URLs | Singleton/Configuración |
| **`cliente_service.dart`** | Operaciones CRUD de clientes | Provider (ChangeNotifier) |
| **`elevador_service.dart`** | Operaciones CRUD de elevadores + asignaciones | Provider (ChangeNotifier) |

**Características comunes**:
- ✅ Todos usan `ApiConfig` para construir las URLs
- ✅ Todos manejan errores de conexión y códigos de estado HTTP
- ✅ Todos convierten JSON a objetos Dart y viceversa
- ✅ `ClienteService` y `ElevadorService` extienden `ChangeNotifier` para notificar cambios
- ✅ Ambos servicios gestionan estados de carga (`isLoading`) y errores (`error`)

**Flujo de comunicación**:
```
Pantalla (UI)
    ↓
Servicio (ClienteService/ElevadorService)
    ↓
ApiConfig (construye URL)
    ↓
HTTP Request (paquete http)
    ↓
API Gateway (puerto 6768)
    ↓
Microservicio correspondiente
    ↓
MySQL Database
```

## Funcionalidades

### Gestión de Clientes

- **Listar clientes**: Ver todos los clientes registrados
- **Crear cliente**: Agregar nuevos clientes con validación de formularios
- **Ver detalles**: Consultar información completa de un cliente
- **Búsqueda por elevador**: Ver clientes asignados a un elevador específico

### Gestión de Elevadores

- **Listar elevadores**: Ver todos los elevadores registrados
- **Crear elevador**: Agregar nuevos elevadores con validación
- **Ver detalles**: Consultar información completa de un elevador
- **Asignar cliente**: Asignar un cliente a un elevador
- **Quitar cliente**: Remover la asignación de un cliente

## Endpoints Utilizados

### Clientes
- `GET /api/cliente/all` - Obtener todos los clientes
- `POST /api/cliente/create` - Crear cliente
- `GET /api/cliente/search/{id}` - Buscar cliente por ID
- `GET /api/cliente/search-by-elevador/{id}` - Buscar clientes por elevador

### Elevadores
- `GET /api/elevador/all` - Obtener todos los elevadores
- `POST /api/elevador/create` - Crear elevador
- `GET /api/elevador/search/{id}` - Buscar elevador por ID
- `GET /api/elevador/search-cliente-by-elevador/{id}` - Buscar clientes asignados
- `PUT /api/elevador/{id}/asignar-cliente/{clienteId}` - Asignar cliente
- `PUT /api/elevador/{id}/quitar-cliente` - Quitar cliente

## Dependencias del Proyecto Flutter

### Dependencias Principales

#### 1. **flutter** (SDK)
- **Versión**: Incluido en Flutter SDK
- **Propósito**: Framework de desarrollo móvil multiplataforma
- **Uso**: Proporciona widgets, herramientas y APIs para construir la interfaz de usuario
- **Archivos que la usan**: Todo el proyecto

#### 2. **http: ^1.1.0**
- **Propósito**: Cliente HTTP para realizar peticiones REST al API Gateway
- **Funcionalidad**: 
  - Realiza peticiones GET, POST, PUT, DELETE
  - Maneja respuestas JSON
  - Gestiona errores de conexión
- **Archivos que la usan**: 
  - `lib/services/cliente_service.dart`
  - `lib/services/elevador_service.dart`
- **Ejemplo de uso**:
  ```dart
  final response = await http.get(
    Uri.parse('${ApiConfig.clienteUrl}/all'),
    headers: {'Content-Type': 'application/json'},
  );
  ```

#### 3. **provider: ^6.1.1**
- **Propósito**: Gestión de estado de la aplicación
- **Funcionalidad**:
  - Maneja el estado global de los servicios (ClienteService, ElevadorService)
  - Notifica cambios a los widgets cuando los datos se actualizan
  - Evita la necesidad de pasar datos manualmente entre widgets
- **Archivos que la usan**:
  - `lib/main.dart` (configuración del provider)
  - `lib/services/cliente_service.dart` (extiende ChangeNotifier)
  - `lib/services/elevador_service.dart` (extiende ChangeNotifier)
  - Todas las pantallas (usan Consumer para escuchar cambios)
- **Ejemplo de uso**:
  ```dart
  Consumer<ClienteService>(
    builder: (context, service, child) {
      return ListView.builder(
        itemCount: service.clientes.length,
        ...
      );
    },
  )
  ```

#### 4. **cupertino_icons: ^1.0.6**
- **Propósito**: Iconos de estilo iOS (Cupertino)
- **Funcionalidad**: Proporciona iconos adicionales para la interfaz
- **Uso**: Iconos en botones, listas y navegación

#### 5. **flutter_svg: ^2.0.9**
- **Propósito**: Renderizar archivos SVG en Flutter
- **Funcionalidad**: Permite usar gráficos vectoriales escalables
- **Nota**: Aunque está incluida, actualmente no se usa en el proyecto

#### 6. **intl: ^0.18.1**
- **Propósito**: Internacionalización y formateo de datos
- **Funcionalidad**:
  - Formateo de fechas, números y monedas
  - Soporte para múltiples idiomas
- **Nota**: Aunque está incluida, actualmente no se usa en el proyecto

### Dependencias de Desarrollo

#### 7. **flutter_test** (SDK)
- **Propósito**: Framework de testing para Flutter
- **Uso**: Escribir y ejecutar pruebas unitarias y de integración

#### 8. **flutter_lints: ^3.0.0**
- **Propósito**: Reglas de linting para código Dart/Flutter
- **Funcionalidad**: 
  - Detecta errores comunes
  - Sugiere mejores prácticas
  - Mantiene consistencia en el código
- **Archivo de configuración**: `analysis_options.yaml`

### Resumen de Dependencias por Funcionalidad

| Dependencia | Propósito Principal | Archivos que la Usan |
|------------|---------------------|---------------------|
| `flutter` | Framework base | Todo el proyecto |
| `http` | Comunicación con API | `cliente_service.dart`, `elevador_service.dart` |
| `provider` | Gestión de estado | `main.dart`, todos los servicios y pantallas |
| `cupertino_icons` | Iconos UI | Pantallas y widgets |
| `flutter_svg` | Gráficos SVG | (No usado actualmente) |
| `intl` | Internacionalización | (No usado actualmente) |

## Tecnologías Utilizadas

### Frontend (Flutter)
- **Flutter**: Framework de desarrollo móvil multiplataforma
- **Dart**: Lenguaje de programación
- **Provider**: Gestión de estado reactivo
- **HTTP**: Cliente HTTP para llamadas API REST
- **Material Design 3**: Sistema de diseño moderno

### Backend (Microservicios)
- **Spring Boot**: Framework Java para microservicios
- **Spring Cloud Gateway**: API Gateway para enrutamiento
- **Netflix Eureka**: Service Discovery y registro de servicios
- **Spring Data JPA**: Persistencia de datos
- **MySQL**: Base de datos relacional
- **Hibernate**: ORM (Object-Relational Mapping)

## Conceptos Técnicos: REST y CORS

### ¿Qué es REST?

**REST** (Representational State Transfer) es un estilo de arquitectura de software para diseñar servicios web. En este proyecto, la aplicación Flutter se comunica con los microservicios backend usando **APIs REST**.

#### Características principales de REST:

1. **Protocolo HTTP**: Utiliza los métodos estándar de HTTP:
   - `GET`: Obtener/leer datos (ejemplo: listar todos los clientes)
   - `POST`: Crear nuevos recursos (ejemplo: crear un nuevo cliente)
   - `PUT`: Actualizar recursos existentes (ejemplo: asignar cliente a elevador)
   - `DELETE`: Eliminar recursos (aunque no se usa en este proyecto)

2. **Sin estado (Stateless)**: Cada petición HTTP contiene toda la información necesaria para procesarla. El servidor no guarda el estado de la sesión del cliente.

3. **Recursos identificados por URLs**: Cada recurso (cliente, elevador) tiene una URL única:
   - `/api/cliente/all` - Todos los clientes
   - `/api/cliente/search/1` - Cliente con ID 1
   - `/api/elevador/create` - Crear un elevador

4. **Formato de datos**: Los datos se intercambian en formato JSON (JavaScript Object Notation), que es fácil de leer y procesar.

#### Ejemplo de petición REST en este proyecto:

```dart
// Flutter App realiza una petición GET
GET http://192.168.2.3:6768/api/cliente/all

// El servidor responde con JSON
{
  "id": 1,
  "nombre": "Juan Pérez",
  "email": "juan@example.com",
  "telefono": "123456789"
}
```

#### ¿Por qué se usa REST en este proyecto?

- **Simplicidad**: Es fácil de entender e implementar
- **Estándar**: Es ampliamente usado y soportado
- **Independencia de plataforma**: Flutter (móvil) puede comunicarse con Spring Boot (Java) sin problemas
- **Escalabilidad**: Permite que diferentes servicios se comuniquen de manera eficiente

### ¿Qué es CORS?

**CORS** (Cross-Origin Resource Sharing) es un mecanismo de seguridad implementado por los navegadores web que permite o restringe las peticiones HTTP entre diferentes orígenes (dominios, puertos o protocolos).

#### ¿Por qué es necesario CORS?

Por defecto, los navegadores aplican la **política de mismo origen (Same-Origin Policy)**, que bloquea peticiones entre diferentes orígenes por seguridad. Sin embargo, en aplicaciones móviles y desarrollo, necesitamos permitir estas peticiones.

**Origen** = Protocolo + Dominio + Puerto

Ejemplos de diferentes orígenes:
- `http://localhost:6768` (API Gateway)
- `http://192.168.2.3:6768` (API Gateway desde dispositivo móvil)
- `http://10.0.2.2:6768` (API Gateway desde emulador Android)

#### ¿Cómo funciona CORS en este proyecto?

1. **Flutter App** (origen: dispositivo móvil) realiza una petición HTTP a:
   - **API Gateway** (origen: `http://192.168.2.3:6768`)

2. **El navegador/Flutter** verifica si el servidor permite peticiones desde ese origen

3. **API Gateway** responde con headers CORS que indican:
   - `Access-Control-Allow-Origin: *` - Permite peticiones desde cualquier origen
   - `Access-Control-Allow-Methods: GET, POST, PUT, DELETE` - Métodos HTTP permitidos
   - `Access-Control-Allow-Headers: Content-Type` - Headers permitidos

4. Si los headers son correctos, la petición se completa exitosamente

#### Configuración de CORS en este proyecto:

**Archivo**: `microservice-gateway/src/main/java/.../CorsGatewayConfig.java`

```java
@Configuration
public class CorsGatewayConfig {
    @Bean
    public CorsWebFilter corsFilter() {
        CorsConfiguration config = new CorsConfiguration();
        config.setAllowCredentials(true);
        config.addAllowedOriginPattern("*");  // Permite todos los orígenes
        config.addAllowedHeader("*");         // Permite todos los headers
        config.addAllowedMethod("*");         // Permite todos los métodos HTTP
        return new CorsWebFilter(source);
    }
}
```

#### ¿Qué sucede si CORS no está configurado?

Si el API Gateway no tiene CORS configurado correctamente, la aplicación Flutter recibirá errores como:
- `CORS policy: No 'Access-Control-Allow-Origin' header is present`
- `Failed to load resource: net::ERR_FAILED`
- Las peticiones HTTP fallarán y la app no podrá comunicarse con el backend

#### Resumen REST vs CORS:

| Concepto | Propósito | Dónde se aplica |
|----------|-----------|----------------|
| **REST** | Estilo de arquitectura para comunicación cliente-servidor | En todas las peticiones HTTP entre Flutter y los microservicios |
| **CORS** | Mecanismo de seguridad para permitir peticiones entre diferentes orígenes | Configurado en el API Gateway para permitir peticiones desde Flutter |

## Detalles de Conexión entre Componentes

### Flutter App → API Gateway

**Configuración en Flutter**:
- Archivo: `lib/services/api_config.dart`
- URL base: `http://192.168.2.3:6768` (o `http://10.0.2.2:6768` para emulador)
- Protocolo: HTTP
- Headers: `Content-Type: application/json`

**Configuración en Gateway**:
- Archivo: `microservice-gateway/src/main/resources/application.yml`
- Puerto: 6768
- Address: `0.0.0.0` (escucha en todas las interfaces)
- CORS: Configurado en `CorsGatewayConfig.java` para permitir todas las peticiones

### API Gateway → Eureka Server

**Configuración en Gateway**:
```yaml
eureka:
  client:
    service-url:
      defaultZone: http://localhost:8761/eureka
```

**Funcionalidad**:
- El gateway se registra en Eureka al iniciar
- Consulta Eureka para descubrir servicios disponibles
- Usa balanceo de carga (`lb://`) para distribuir peticiones

### API Gateway → Microservicios

**Rutas Configuradas**:

1. **Microservicio Cliente**:
   - Path: `/api/cliente/**`
   - Servicio: `msvc-cliente`
   - Puerto interno: 8001
   - Base de datos: MySQL `microservicebd`

2. **Microservicio Elevador**:
   - Path: `/api/elevador/**`
   - Servicio: `msvc-elevador`
   - Puerto interno: 8002
   - Base de datos: MySQL `microservicebd`

**Flujo de Enrutamiento**:
```
Petición: GET /api/cliente/all
    ↓
Gateway verifica path: /api/cliente/**
    ↓
Gateway busca servicio: msvc-cliente en Eureka
    ↓
Eureka retorna: localhost:8001
    ↓
Gateway enruta: GET http://localhost:8001/api/cliente/all
    ↓
Cliente Service procesa y retorna respuesta
    ↓
Gateway retorna respuesta a Flutter App
```

### Microservicios → MySQL Database

**Configuración en ambos microservicios**:
```yaml
datasource:
  url: jdbc:mysql://localhost:3306/microservicebd
  username: root
  password: 
  driver-class-name: com.mysql.cj.jdbc.Driver
```

**Tablas**:
- `db_clientes`: Almacena información de clientes
- `db_elevadores`: Almacena información de elevadores

## Notas Importantes

1. **Conexión de red**: Asegúrate de que el dispositivo/emulador pueda acceder al servidor del API Gateway
2. **CORS**: El gateway tiene configurado CORS en `CorsGatewayConfig.java` para permitir todas las peticiones
3. **Permisos**: La aplicación requiere permisos de internet en Android (ya incluidos por defecto)
4. **Microservicios obligatorios**: 
   - ⚠️ **El microservicio Cliente (`microservice-clientes-ele`) DEBE estar activo** - Sin él, ninguna funcionalidad de clientes funcionará
   - ⚠️ **El microservicio Elevador (`microservice-elevadores-cli`) DEBE estar activo** - Sin él, ninguna funcionalidad de elevadores funcionará
   - La aplicación Flutter es solo una interfaz de usuario y depende completamente de estos microservicios para procesar datos
5. **Orden de inicio**: 
   - Primero: MySQL Database
   - Segundo: Eureka Server
   - Tercero: Microservicios (Cliente y Elevador) - **AMBOS deben estar activos**
   - Cuarto: API Gateway
   - Último: Flutter App
6. **Service Discovery**: Los microservicios deben estar registrados en Eureka antes de que el gateway pueda enrutar peticiones. Si un microservicio no está activo, el gateway no podrá enrutar peticiones a ese servicio y la app mostrará errores

## Solución de Problemas

### Error de conexión
- Verifica que el backend esté ejecutándose
- Confirma que la URL en `api_config.dart` sea correcta
- Para dispositivo físico, usa la IP local de tu máquina, no `localhost`

### Error 404 o 503 (Service Unavailable)
- Verifica que el API Gateway esté ejecutándose en el puerto 6768
- Confirma que las rutas en el gateway estén configuradas correctamente
- **⚠️ IMPORTANTE**: Verifica que ambos microservicios estén activos:
  - `microservice-clientes-ele` debe estar corriendo en el puerto 8001
  - `microservice-elevadores-cli` debe estar corriendo en el puerto 8002
- Verifica en Eureka (http://localhost:8761) que ambos servicios estén registrados y en estado "UP"
- Si un microservicio no está activo, el gateway no podrá enrutar las peticiones y recibirás errores 503 o 404

### Error de CORS
- Asegúrate de que el gateway tenga configurado CORS para permitir peticiones desde Flutter

### La app muestra "Error al cargar datos" o "No se pudo conectar"
- **Primero verifica**: ¿Están ambos microservicios activos?
  - Microservicio Cliente: `http://localhost:8001/actuator/health` (debe responder)
  - Microservicio Elevador: `http://localhost:8002/actuator/health` (debe responder)
- Verifica que Eureka Server esté ejecutándose (puerto 8761)
- Verifica que MySQL esté ejecutándose y accesible (puerto 3306)
- Revisa los logs de los microservicios para ver si hay errores de conexión a la base de datos

## Desarrollo

Para contribuir o modificar la aplicación:

1. Clona el repositorio
2. Instala las dependencias: `flutter pub get`
3. Configura la URL del API en `api_config.dart`
4. Ejecuta la aplicación: `flutter run`

## Licencia

Este proyecto es parte del sistema de microservicios de gestión de elevadores y clientes.

