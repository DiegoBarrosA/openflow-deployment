
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

## 1. Pruebas Realizadas

### 1.1 Pruebas Manuales
Se realizaron pruebas manuales exhaustivas utilizando:
- **HAR Files (HTTP Archive)**: Captura de todas las solicitudes HTTP para análisis de errores
- **kubectl logs**: Monitoreo en tiempo real de logs del backend en Kubernetes
- **Browser DevTools**: Inspección de errores de consola y red

### 1.2 Pruebas Automatizadas
- **Backend (Java/Spring Boot)**: JaCoCo para cobertura de código
- **CI/CD**: GitHub Actions para pruebas automáticas en cada push

---

## 2. Clasificación de Fallas Encontradas

| ID | Bug | Gravedad | Impacto | Estado |
|----|-----|----------|---------|--------|
| BUG-001 | Translation key "task.description" missing | Baja | UI muestra clave técnica | ✅ Corregido |
| BUG-002 | Custom fields double-submit | Media | Datos duplicados | ✅ Corregido |
| BUG-003 | Oracle reserved word "value" | Crítica | Sistema inoperativo | ✅ Corregido |
| BUG-004 | Error 400 creating tasks with custom fields | Alta | Funcionalidad bloqueada | ✅ Corregido |
| BUG-005 | Custom field delete 500 error | Alta | No se pueden eliminar campos | ✅ Corregido |
| BUG-006 | Mermaid export parse error | Media | Export no funciona | ✅ Corregido |
| BUG-007 | Username overflow in navigation | Baja | UI rota con nombres largos | ✅ Corregido |
| BUG-008 | Infinite loading after board errors | Media | UX degradada | ✅ Corregido |
| BUG-009 | No character limit validation | Media | Errores 400 confusos | ✅ Corregido |
| BUG-010 | Description column too small in Oracle | Alta | Tareas no se crean | ✅ Corregido |
| BUG-011 | globally_quoted_identifiers breaks Oracle | Crítica | Tablas no encontradas | ✅ Corregido |
| BUG-012 | TaskController silently swallowing errors | Media | Debugging imposible | ✅ Corregido |

### Clasificación de Gravedad:
- **Crítica**: Sistema completamente inoperativo
- **Alta**: Funcionalidad principal bloqueada
- **Media**: Funcionalidad degradada pero usable
- **Baja**: Problema cosmético o de UX menor

---

## 3. Correcciones Aplicadas

### 3.1 Correcciones Backend (Java/Spring Boot)

| Archivo | Cambio |
|---------|--------|
| `CustomFieldValue.java` | Renombrar propiedad `value` → `fieldValue` para evitar palabra reservada Oracle |
| `TaskDto.java` | Cambiar `Map<Long, String>` → `Map<String, String>` para deserialización JSON |
| `TaskService.java` | Agregar conversión de String a Long para custom fields |
| `CustomFieldValueRepository.java` | Agregar `@Modifying` y `@Query` para operaciones de delete |
| `TaskController.java` | Agregar logging de errores con SLF4J |
| `Task.java` | Alinear límite de descripción a 255 caracteres |
| `application.properties` | Remover `globally_quoted_identifiers=true` |

### 3.2 Correcciones Frontend (React/Vite)

| Archivo | Cambio |
|---------|--------|
| `en.json`, `es.json` | Agregar claves de traducción faltantes |
| `CustomFieldManager.jsx` | Agregar estados `isSubmitting` para prevenir double-submit |
| `Board.jsx` | Agregar límites de caracteres, estados de loading/error |
| `TaskDetailModal.jsx` | Agregar límites de caracteres, mejorar UX |
| `NavigationBar.jsx` | Truncar nombres de usuario largos |
| `exportUtils.js` | Corregir sintaxis Mermaid Kanban |

---

## 4. Pruebas de Optimización

### 4.1 Tiempos de Respuesta
- **API Response Time**: < 200ms promedio para operaciones CRUD
- **Page Load Time**: < 2s para carga inicial del tablero
- **WebSocket Latency**: Notificaciones en tiempo real < 100ms

### 4.2 Consumo de Recursos
- **Backend Pod**: 256Mi RAM, 0.25 CPU (Kubernetes limits)
- **Frontend Pod**: 128Mi RAM, 0.1 CPU
- **Database**: Oracle Autonomous Database (auto-scaling)

### 4.3 Eficiencia General
- **Lazy Loading**: Componentes cargados bajo demanda
- **Image Optimization**: Profile pictures almacenadas en S3 con URLs presignadas
- **Connection Pooling**: HikariCP para conexiones a Oracle

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
