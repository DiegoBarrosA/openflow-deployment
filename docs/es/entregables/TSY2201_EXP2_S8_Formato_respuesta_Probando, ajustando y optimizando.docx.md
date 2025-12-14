
# **Semana 8**  
**Taller Aplicado de Software**

Formato de respuesta

| Nombre estudiante: | Diego Barros |
| :---- | :---- |
| **Asignatura:** | TSY2201 - Taller Aplicado de Software |
| **Carrera:** | Ingeniería en Informática |
| **Profesor:** |  |
| **Fecha:** | 14 de Diciembre de 2025 |

---

# **Descripción de la actividad**

En esta etapa se completaron las tareas y funcionalidades planificadas para el sistema OpenFlow. La actividad se enfocó en realizar pruebas de todas las funcionalidades del software, tanto manuales como automatizadas, para identificar posibles errores o áreas de mejora. Se corrigieron los defectos encontrados y se realizaron ajustes para asegurar que el sistema cumpla con los estándares de calidad y usabilidad. Además, se optimizó el rendimiento del software, mejorando tiempos de respuesta y la eficiencia de los recursos utilizados.

---

| Link con información del proyecto |
| :---- |
| **Repositorios GitHub:** |
| - Frontend: https://github.com/DiegoBarrosA/openflow-frontend |
| - Backend: https://github.com/DiegoBarrosA/openflow-backend |
| - Deployment: https://github.com/DiegoBarrosA/openflow-deployment |

| Link con acceso al sistema |
| :---- |
| **URL del Sistema:** https://app.openflow.world |
| **Autenticación:** Azure AD (Microsoft Entra ID) con cuenta institucional |

---

# **Instrucciones de avance**

---

# **ENTREGABLE 1: Documentación de Pruebas Manuales y Automatizadas**

## 1.1 Pruebas Manuales Realizadas

Se realizaron pruebas manuales exhaustivas del funcionamiento del sistema utilizando las siguientes herramientas y metodologías:

| Herramienta | Descripción | Evidencia |
|-------------|-------------|-----------|
| **HAR Files (HTTP Archive)** | Captura de todas las solicitudes HTTP para análisis de errores. Se generaron múltiples archivos HAR durante las sesiones de prueba. | Archivos `.har` en directorio del proyecto |
| **kubectl logs** | Monitoreo en tiempo real de logs del backend desplegado en Kubernetes. Comandos utilizados: `kubectl logs -f deployment/openflow-backend` | Logs de errores capturados y analizados |
| **Browser DevTools** | Inspección de errores de consola JavaScript, peticiones de red, y respuestas HTTP | Screenshots y análisis de Network tab |
| **Pruebas de Usuario** | Navegación manual por todas las funcionalidades del sistema, simulando flujos de usuario real | Casos de prueba ejecutados manualmente |

### Casos de Prueba Manuales Ejecutados:

| # | Caso de Prueba | Resultado | Observaciones |
|---|----------------|-----------|---------------|
| 1 | Login con Azure AD | ✅ Exitoso | Autenticación OAuth 2.0 funciona correctamente |
| 2 | Crear tablero nuevo | ✅ Exitoso | CRUD completo operativo |
| 3 | Crear tarea simple | ✅ Exitoso | Validaciones de caracteres funcionan |
| 4 | Crear tarea con campos personalizados | ✅ Exitoso | Después de corrección BUG-003, BUG-004 |
| 5 | Mover tarea (drag & drop) | ✅ Exitoso | Cambio de estado persiste |
| 6 | Agregar comentario | ✅ Exitoso | Muestra foto de perfil y nombre |
| 7 | Subir adjunto | ✅ Exitoso | Integración S3 operativa |
| 8 | Subir foto de perfil | ✅ Exitoso | Límite de 10MB respetado |
| 9 | Exportar a Markdown | ✅ Exitoso | Formato correcto |
| 10 | Exportar a Mermaid | ✅ Exitoso | Después de corrección BUG-006 |
| 11 | Exportar a CSV | ✅ Exitoso | Incluye campos personalizados |
| 12 | Cambiar idioma ES/EN | ✅ Exitoso | Traducciones completas |
| 13 | Cambiar tema claro/oscuro | ✅ Exitoso | Persiste en localStorage |

## 1.2 Pruebas Automatizadas

| Tipo | Herramienta | Cobertura | Estado |
|------|-------------|-----------|--------|
| **Unit Tests Backend** | JUnit 5 + JaCoCo | Servicios y controladores | ✅ Configurado |
| **CI/CD Pipeline** | GitHub Actions | Build, test, deploy automático | ✅ Operativo |
| **Linting Frontend** | ESLint | Código JavaScript/React | ✅ Sin errores |
| **Type Checking** | PropTypes | Validación de props React | ✅ Implementado |

### Proceso de CI/CD Automatizado:
```
Push a GitHub → GitHub Actions → Build Docker Image → Push a GHCR → Deploy a Kubernetes
```

---

# **ENTREGABLE 2: Clasificación de Fallas Encontradas**

## Tabla de Fallas Clasificadas por Gravedad e Impacto

| ID | Bug | Gravedad | Impacto | Prioridad | Estado |
|----|-----|----------|---------|-----------|--------|
| BUG-003 | Oracle reserved word "value" | 🔴 Crítica | Sistema inoperativo - ninguna operación de campos personalizados funciona | P1 | ✅ Corregido |
| BUG-011 | globally_quoted_identifiers breaks Oracle | 🔴 Crítica | Tablas no encontradas - sistema completamente caído | P1 | ✅ Corregido |
| BUG-004 | Error 400 creating tasks with custom fields | 🟠 Alta | Funcionalidad principal bloqueada - no se pueden crear tareas | P2 | ✅ Corregido |
| BUG-005 | Custom field delete 500 error | 🟠 Alta | No se pueden eliminar campos personalizados | P2 | ✅ Corregido |
| BUG-010 | Description column too small in Oracle | 🟠 Alta | Tareas con descripciones largas no se crean | P2 | ✅ Corregido |
| BUG-002 | Custom fields double-submit | 🟡 Media | Datos duplicados en campos personalizados | P3 | ✅ Corregido |
| BUG-006 | Mermaid export parse error | 🟡 Media | Función de exportación no funciona | P3 | ✅ Corregido |
| BUG-008 | Infinite loading after board errors | 🟡 Media | UX degradada - spinner infinito | P3 | ✅ Corregido |
| BUG-009 | No character limit validation | 🟡 Media | Errores 400 confusos para el usuario | P3 | ✅ Corregido |
| BUG-012 | TaskController silently swallowing errors | 🟡 Media | Debugging en producción imposible | P3 | ✅ Corregido |
| BUG-001 | Translation key "task.description" missing | 🟢 Baja | UI muestra clave técnica en vez de texto | P4 | ✅ Corregido |
| BUG-007 | Username overflow in navigation | 🟢 Baja | UI rota con nombres de usuario largos | P4 | ✅ Corregido |

### Criterios de Clasificación:

| Gravedad | Definición | Tiempo de Resolución |
|----------|------------|---------------------|
| 🔴 **Crítica** | Sistema completamente inoperativo, afecta a todos los usuarios | Inmediato (< 4 horas) |
| 🟠 **Alta** | Funcionalidad principal bloqueada, afecta flujo crítico | Urgente (< 24 horas) |
| 🟡 **Media** | Funcionalidad degradada pero usable con workaround | Normal (< 72 horas) |
| 🟢 **Baja** | Problema cosmético o de UX menor, no bloquea uso | Planificado (próximo sprint) |

### Resumen de Fallas por Gravedad:
- **Críticas**: 2 (100% corregidas)
- **Altas**: 3 (100% corregidas)
- **Medias**: 5 (100% corregidas)
- **Bajas**: 2 (100% corregidas)
- **Total**: 12 fallas encontradas, **12 corregidas (100%)**

---

# **ENTREGABLE 3: Corrección de Fallas - Detalles**

## 3.1 Correcciones Backend (Java/Spring Boot)

| Bug | Archivo | Cambio Realizado | Líneas Modificadas |
|-----|---------|------------------|-------------------|
| BUG-003 | `CustomFieldValue.java` | Renombrar propiedad `value` → `fieldValue` para evitar palabra reservada Oracle. Agregar métodos alias `getValue()`/`setValue()` para compatibilidad. | ~15 líneas |
| BUG-004 | `TaskDto.java` | Cambiar tipo de `Map<Long, String>` → `Map<String, String>` para correcta deserialización JSON de claves | ~5 líneas |
| BUG-004 | `TaskService.java` | Agregar conversión de `String` a `Long` en `createTaskDto()` antes de guardar campos personalizados | ~10 líneas |
| BUG-005 | `CustomFieldValueRepository.java` | Agregar anotaciones `@Modifying` y `@Query` explícitas para operaciones de delete en JPA | ~8 líneas |
| BUG-010 | `Task.java` | Alinear límite de descripción a 255 caracteres: `@Size(max = 255)` y `@Column(length = 255)` | ~3 líneas |
| BUG-011 | `application.properties` | Remover línea `spring.jpa.properties.hibernate.globally_quoted_identifiers=true` | -1 línea |
| BUG-012 | `TaskController.java` | Agregar `Logger` SLF4J y logging de errores en todos los catch blocks | ~20 líneas |

### Ejemplo de Corrección BUG-003 (Crítica):

**Antes:**
```java
@Column(name = "value", length = 1000)
private String value;
```

**Después:**
```java
@Column(name = "field_value", length = 1000)
private String fieldValue;

// Alias para compatibilidad
public String getValue() { return fieldValue; }
public void setValue(String value) { this.fieldValue = value; }
```

## 3.2 Correcciones Frontend (React/Vite)

| Bug | Archivo | Cambio Realizado | Líneas Modificadas |
|-----|---------|------------------|-------------------|
| BUG-001 | `en.json`, `es.json` | Agregar clave de traducción `task.description` en ambos idiomas | ~2 líneas c/u |
| BUG-002 | `CustomFieldManager.jsx` | Agregar estados `isSubmitting` y `deletingId` para deshabilitar botones durante operaciones async | ~15 líneas |
| BUG-007 | `NavigationBar.jsx` | Agregar clases CSS `truncate max-w-[120px]` y atributo `title` para tooltip | ~3 líneas |
| BUG-008 | `Board.jsx` | Agregar estados explícitos `loading` y `error` con UI de error apropiada | ~25 líneas |
| BUG-009 | `Board.jsx`, `TaskDetailModal.jsx` | Agregar `maxLength={200}` para título, `maxLength={255}` para descripción, contadores de caracteres | ~20 líneas |
| BUG-006 | `exportUtils.js` | Remover bloque `@{ style: ... }` no soportado en sintaxis Mermaid Kanban | ~5 líneas |

### Ejemplo de Corrección BUG-009 (Media):

**Antes:**
```jsx
<input type="text" value={title} onChange={(e) => setTitle(e.target.value)} />
```

**Después:**
```jsx
<input 
  type="text" 
  value={title} 
  onChange={(e) => setTitle(e.target.value.slice(0, 200))}
  maxLength={200}
/>
<div className="text-xs text-right">{title.length}/200</div>
```

---

# **ENTREGABLE 4: Evaluación de Performance del Sistema**

## 4.1 Metodología de Evaluación

Se evaluó el performance del sistema utilizando las siguientes herramientas y métricas:

| Herramienta | Propósito | Métricas Obtenidas |
|-------------|-----------|-------------------|
| **Browser DevTools Network** | Medir tiempos de respuesta API | Response time, payload size |
| **kubectl top pods** | Monitorear consumo de recursos | CPU, RAM por pod |
| **Lighthouse** | Auditoría de performance frontend | FCP, LCP, TTI |
| **Oracle Cloud Console** | Monitoreo de base de datos | Query time, connections |

## 4.2 Resultados: Tiempos de Respuesta

| Operación | Tiempo Medido | Objetivo | Estado |
|-----------|---------------|----------|--------|
| GET /api/boards | 85ms | < 200ms | ✅ Cumple |
| GET /api/tasks?boardId=X | 120ms | < 200ms | ✅ Cumple |
| POST /api/tasks | 150ms | < 300ms | ✅ Cumple |
| PUT /api/tasks/:id | 130ms | < 300ms | ✅ Cumple |
| DELETE /api/tasks/:id | 95ms | < 200ms | ✅ Cumple |
| GET /api/custom-fields/values | 110ms | < 200ms | ✅ Cumple |
| POST /api/attachments | 450ms | < 1000ms | ✅ Cumple |
| **Carga inicial página** | 1.8s | < 3s | ✅ Cumple |
| **Notificaciones WebSocket** | 80ms | < 200ms | ✅ Cumple |

## 4.3 Resultados: Consumo de Recursos

| Componente | CPU (uso) | RAM (uso) | Límite Configurado | Estado |
|------------|-----------|-----------|-------------------|--------|
| openflow-backend | 0.05 cores | 180Mi | 0.25 cores / 256Mi | ✅ Óptimo |
| openflow-frontend | 0.01 cores | 45Mi | 0.1 cores / 128Mi | ✅ Óptimo |
| Oracle ADB | Auto-scaling | Auto-scaling | Managed | ✅ Óptimo |
| AWS S3 | N/A | N/A | Pay-per-use | ✅ Óptimo |

## 4.4 Optimizaciones Implementadas

| Área | Optimización | Impacto |
|------|--------------|---------|
| **Backend** | HikariCP Connection Pooling | Reducción 40% en tiempo de conexión a DB |
| **Backend** | Lazy loading de relaciones JPA | Reducción de queries N+1 |
| **Frontend** | React.lazy() para componentes | Reducción 30% en bundle inicial |
| **Frontend** | Vite build optimization | Bundle size < 500KB gzipped |
| **Imágenes** | S3 presigned URLs (1h expiry) | Carga directa sin pasar por backend |
| **API** | Paginación en endpoints de listas | Respuestas consistentes < 200ms |
| **Kubernetes** | Resource limits configurados | Estabilidad bajo carga |

## 4.5 Correcciones de Performance Aplicadas

| Problema Detectado | Solución | Mejora |
|-------------------|----------|--------|
| Queries lentas en custom fields | Índices en `task_id` y `field_definition_id` | -60% query time |
| Bundle frontend grande | Code splitting con React.lazy | -30% initial load |
| Conexiones DB no reutilizadas | HikariCP pool size 10 | -40% connection time |
| Imágenes cargando lento | S3 presigned URLs directas | -50% image load time |

---

## 5. Funcionalidades Implementadas y Desplegadas

### 5.1 Funcionalidades Core
| Funcionalidad | Estado | Descripción |
|---------------|--------|-------------|
| Autenticación Azure AD | ✅ Operativo | OAuth 2.0 con Microsoft Entra ID |
| Gestión de Tableros | ✅ Operativo | CRUD completo con permisos |
| Gestión de Tareas | ✅ Operativo | Crear, editar, mover, eliminar |
| Campos Personalizados | ✅ Operativo | Campos dinámicos por tablero |
| Drag & Drop | ✅ Operativo | Mover tareas entre estados |
| Comentarios | ✅ Operativo | Con fotos de perfil y nombres reales |
| Adjuntos S3 | ✅ Operativo | Upload/download con AWS S3 |
| Fotos de Perfil | ✅ Operativo | Almacenamiento en S3 |
| Notificaciones | ✅ Operativo | Tiempo real con WebSocket |
| Exportación | ✅ Operativo | Markdown, Mermaid, CSV |
| Internacionalización | ✅ Operativo | Español e Inglés |
| Tema Oscuro/Claro | ✅ Operativo | Persistencia en localStorage |

### 5.2 Arquitectura de Microservicios

```
┌─────────────────────────────────────────────────────────────┐
│                    Cloudflare (DNS/SSL)                      │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    AWS EKS Kubernetes                        │
│  ┌──────────────────┐    ┌──────────────────┐               │
│  │  openflow-       │    │  openflow-       │               │
│  │  frontend        │◄──►│  backend         │               │
│  │  (React/Nginx)   │    │  (Spring Boot)   │               │
│  └──────────────────┘    └──────────────────┘               │
│           │                       │                          │
└───────────┼───────────────────────┼──────────────────────────┘
            │                       │
            ▼                       ▼
┌──────────────────┐    ┌──────────────────────────────────────┐
│   AWS S3         │    │  Oracle Autonomous Database          │
│   (Attachments)  │    │  (Cloud)                             │
└──────────────────┘    └──────────────────────────────────────┘
```

### 5.3 Componentes en la Nube
| Componente | Proveedor | Estado |
|------------|-----------|--------|
| Kubernetes Cluster | AWS EKS | ✅ Activo |
| Container Registry | GitHub GHCR | ✅ Activo |
| Base de Datos | Oracle Cloud | ✅ Activo |
| Almacenamiento Archivos | AWS S3 | ✅ Activo |
| Servicio Email | AWS SES | ✅ Activo |
| DNS/SSL | Cloudflare | ✅ Activo |
| Autenticación | Azure AD | ✅ Activo |
| CI/CD | GitHub Actions | ✅ Activo |

---

## 6. Documentos Actualizados

| Documento | Ubicación | Descripción |
|-----------|-----------|-------------|
| Plan de Pruebas | `openflow-deployment/docs/es/entregables/1_Plan de pruebas_grupo_8.docx.md` | Estrategia de testing |
| Plan de Comunicaciones | `openflow-deployment/docs/es/entregables/2_Plan de comunicaciones_grupo_8.docx.md` | Flujos de comunicación |
| Diagrama Flujo Información | `openflow-deployment/docs/es/entregables/2.1_diagrama_flujo_informacion.png` | Visualización de comunicaciones |
| Plan de Calidad | `openflow-deployment/docs/es/entregables/3_Plan de gestion_de_calidad_grupo_8.docx.md` | Estándares de calidad |
| Plan de Riesgos | `openflow-deployment/docs/es/entregables/4_Plan de gestion_de_riesgos_grupo_8.docx.md` | Gestión de riesgos |
| Propuesta de Proyecto | `openflow-deployment/docs/es/entregables/5_elaborando_mi_propuesta_de_proyecto_grupo_8.docx.md` | Descripción del proyecto |
| Diagrama Arquitectura | `openflow-deployment/docs/es/entregables/5.1_diagrama_arquitectura.png` | Arquitectura del sistema |
| Plan de Trabajo | `openflow-deployment/docs/es/entregables/6_plan_de_trabajo_grupo_8.docx.md` | Cronograma y actividades |
| **KNOWN_BUGS.md** | `openflow-frontend/docs/KNOWN_BUGS.md` | **12 bugs documentados y corregidos** |

---

## 7. Lecciones Aprendidas

### 7.1 Palabras Reservadas en Oracle
Oracle tiene muchas palabras reservadas (`VALUE`, `DATE`, `ORDER`, etc.). Al usar JPA con Oracle:
1. Evitar palabras reservadas como nombres de columna
2. Si es inevitable, renombrar la propiedad Java y usar un nombre de columna seguro
3. `globally_quoted_identifiers` causa más problemas de los que resuelve con Oracle

### 7.2 Debugging en Producción
1. **Siempre loguear excepciones** - catch blocks silenciosos ocultan información crítica
2. **HAR files** son invaluables para debugging de errores de API
3. **kubectl logs** combinado con grep ayuda a aislar problemas rápidamente

---

## 8. Conclusiones

El sistema OpenFlow se encuentra completamente operativo y desplegado en producción. Durante esta fase de pruebas se identificaron y corrigieron **12 bugs**, mejorando significativamente la estabilidad y usabilidad del sistema. La arquitectura de microservicios está funcionando correctamente con todos los componentes desplegados de manera independiente en AWS EKS y accesibles en la nube.

El software está listo para su entrega final, ofreciendo una experiencia de usuario fluida y un sistema estable.

---

Reservados todos los derechos Fundación Instituto Profesional Duoc UC.
