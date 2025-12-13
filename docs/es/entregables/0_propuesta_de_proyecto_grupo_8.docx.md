

# 

**Semana 1**  
**Taller Aplicado de Software**

Formato de respuesta

| Nombre estudiante(s): Diego Barros Rodrigo Escala |  |
| :---- | :---- |
| **Asignatura: Taller Aplicado de Software** | **Carrera: Ingeniería En Desarrollo De Software** |
| **Profesor: Alonso Esteban Castillo Pizarro** | **Fecha: 27-10-2025** |

# **Descripción de la actividad**

En esta **actividad en parejas** deberás establecer los aspectos principales del proyecto considerando la realización de una declaración del mercado objetivo con el fin de determinar el alcance del proyecto y establecer objetivos claros, medibles y alcanzables alineados con los requisitos de los interesados. **Si tienes alguna consulta, no dudes en contactar a tu docente.**

## **Instrucciones específicas**

A continuación, deberás completar cada uno de los siguientes recuadros con la información que se solicita. Si tienes alguna consulta, no dudes en contactar a tu docente. 

### **Parte I ** 

| 1\. Nombre del proyecto  | Openflow: Plataforma Kanban Open-Source para Equipos Ágiles |
| :---- | :---- |

| 2\. Descripción Proyecto |
| :---- |
| Openflow es una plataforma de gestión de tareas tipo Kanban diseñada para ofrecer flexibilidad, personalización y transparencia en la organización de proyectos. Su propósito principal es proporcionar una alternativa open-source a herramientas propietarias como Trello, pero con mayor capacidad de adaptación a flujos de trabajo personalizados y necesidades de equipos pequeños, proyectos colaborativos y comunidades de software libre. **Funcionalidades principales:** Creación de tableros Kanban con columnas y campos personalizables Gestión de tareas con funcionalidad de arrastrar y soltar Soporte para equipos remotos y proyectos públicos API abierta para integraciones con otras herramientas Arquitectura escalable basada en estándares cloud-native **Tipos de Usuarios y Funcionalidades** En el sistema Openflow, se han identificado tres tipos de usuarios con diferentes niveles de acceso y funcionalidades: **Administrador**: **Funcionalidades**: Crear y gestionar tableros. Crear, eliminar y renombrar columnas/estados. Gestionar el acceso de usuarios a los tableros. **Usuario Normal**: **Funcionalidades**: Crear tareas. Mover tareas entre columnas. Modificar tareas. Comentar en tareas. **Usuario No Autenticado**: **Funcionalidades**: Ver tableros y tareas.  **Contexto:** En un entorno laboral donde la agilidad y la colaboración son clave, Openflow busca llenar el vacío dejado por soluciones existentes que son rígidas, difíciles de desplegar o carecen de características modernas de personalización. La plataforma se enfoca en equipos que necesitan una solución ágil, económica y adaptable a sus procesos específicos, especialmente en el ámbito del desarrollo de software y proyectos comunitarios.  |

 

| 3\. Fundamentación Proyecto |
| :---- |

 

| Relevancia del proyecto | Problemática: Las herramientas de gestión de tareas actuales presentan limitaciones significativas: Soluciones propietarias como Trello tienen costos recurrentes y limitaciones de personalización Alternativas open-source como Taiga, Wekan y Kanboard requieren configuraciones complejas, carecen de características modernas o tienen problemas de escalabilidad La mayoría no están diseñadas para proyectos que requieren transparencia pública (como iniciativas de software libre) Falta de integración nativa con tecnologías cloud-native y estándares abiertos Oportunidad de mejora: Openflow aborda estas limitaciones mediante: Una arquitectura basada en contenedores y microservicios que facilita el despliegue Interfaz personalizable que se adapta a diferentes metodologías de trabajo Enfoque en estándares abiertos que permite integraciones con otras herramientas Diseño centrado en la usabilidad para equipos no técnicos Aporte de valor:  Para equipos de desarrollo: Herramienta ágil y adaptable a sus flujos de trabajo Para proyectos de software libre: Plataforma transparente y colaborativa Para organizaciones educativas: Solución económica y escalable Para el campo laboral: Contribuye al ecosistema de herramientas open-source para gestión de proyectos |
| :---- | :---- |
| **Factibilidad de desarrollo del Proyecto** | Duración del bimestre (9 semanas): El proyecto se ha estructurado en fases realistas que permiten desarrollar un MVP funcional dentro del plazo establecido, priorizando las funcionalidades esenciales (tableros, tareas, autenticación) y dejando características avanzadas (como integración con IA) para futuras iteraciones. **Materiales requeridos:**  Tecnologías accesibles: Docker, Kubernetes, PostgreSQL, React Herramientas de desarrollo: GitHub, VS Code, Postman/Bruno Infraestructura: AWS Free Tier para despliegue y Azure students. Recursos humanos: Equipo con experiencia en desarrollo full-stack y DevOps **Factores externos:**   **Facilitadores:**  Disponibilidad de documentación y comunidades activas para las tecnologías seleccionadas Experiencia previa del equipo en proyectos similares Acceso a recursos educativos y plantillas open-source **Obstáculos potenciales:**  Curva de aprendizaje en tecnologías cloud-native para algunos miembros del equipo Posibles limitaciones en la capa gratuita de AWS Dependencia de la disponibilidad de tiempo del equipo **Estrategias de mitigación:**  Capacitación inicial en Kubernetes y AWS Uso de alternativas locales si hay limitaciones con AWS Planificación con buffers de tiempo para imprevistos |
| **Mercado Objetivo** | **Problema que resuelve:** Falta de una herramienta de gestión de tareas que combine flexibilidad, facilidad de despliegue y enfoque open-source, especialmente para equipos pequeños y proyectos colaborativos que requieren transparencia y personalización. **Perfil del cliente ideal:**  **Equipos de desarrollo ágil (3-10 miembros)** que necesitan adaptar su herramienta de gestión a metodologías específicas **Proyectos de software libre** que requieren transparencia en su gestión de tareas **Organizaciones educativas y sin fines de lucro** que buscan soluciones económicas y escalables **Freelancers y profesionales independientes** que necesitan una herramienta simple pero potente para organizar su trabajo **Tendencias del mercado:**  Creciente adopción de metodologías ágiles en diversos sectores Aumento en la demanda de herramientas open-source y autoalojadas a causa de politic Necesidad de soluciones que se integren con otros sistemas (APIs, webhooks) Preferencia por plataformas que ofrezcan personalización sin complejidad **Adaptación a necesidades:** Openflow se diseña con: Interfaz intuitiva para usuarios no técnicos Opciones de personalización para adaptarse a diferentes flujos de trabajo Arquitectura escalable que crece con las necesidades del equipo Enfoque en la privacidad y control de datos [**Tabla Comparativa de Soluciones Similares**](#tabla-comparativa-de-soluciones-similares) |

### 

| 4\. Objetivos |
| :---- |
| En este apartado debes definir objetivo general y específicos del proyecto. Es importante aclarar que los objetivos se deben plantear en forma clara, concisa y sin dar mayores explicaciones, es decir, deben entenderse por sí solos. Se sugiere redactarlos utilizando un verbo en infinitivo, pues ello obliga a precisar acciones concretas. |

 

| Objetivo general | Desarrollar una plataforma Kanban open-source, escalable y personalizable que facilite la gestión de tareas para equipos pequeños y proyectos colaborativos, proporcionando una alternativa flexible, económica y transparente a las soluciones propietarias actuales, y contribuyendo al ecosistema de herramientas open-source para gestión de proyectos. |
| :---- | :---- |
| **Objetivos específicos** | **Diseñar e implementar una interfaz de usuario intuitiva** *Específico:* Crear una interfaz responsive que permita la gestión visual de tableros Kanban con columnas y tareas personalizables *Medible:* Prototipo funcional validado con al menos 2 usuarios finales *Alcanzable:* Utilizando frameworks como React y librerías de UI como Material-UI *Relevante:* La interfaz es el punto de contacto principal con los usuarios *Temporal:* Para la fase inicial del proyecto **Desarrollar una arquitectura escalable basada en microservicios** *Específico:* Implementar la plataforma usando contenedores Docker y orquestación con Kubernetes *Medible:* Entorno desplegado localmente y en la nube con métricas de rendimiento *Alcanzable:* Utilizando tecnologías conocidas por el equipo (Docker, Kubernetes) *Relevante:* Garantiza la escalabilidad y portabilidad del sistema *Temporal:* Para la mitad del período de desarrollo **Implementar un sistema de autenticación y autorización seguro** *Específico:* Crear un sistema de autenticación basado en JWT y OAuth 2.0 *Medible:* La mayoría de los endpoints protegidos y pruebas de seguridad aprobadas *Alcanzable:* Utilizando librerías estándar y buenas prácticas de seguridad *Relevante:* Esencial para proteger la privacidad de los datos *Temporal:* Para la fase intermedia del proyecto **Crear una API bien documentada para integraciones** *Específico:* Desarrollar una API RESTful documentada con OpenAPI 3.0 *Medible:* Documentación completa y pruebas de todos los endpoints principales *Alcanzable:* Utilizando herramientas como Swagger y Postman *Relevante:* Permite la extensión y integración con otras herramientas *Temporal:* Para la fase intermedia del proyecto **Publicar el proyecto como software open-source** *Específico:* Liberar el código bajo licencia MIT o GPL con documentación completa *Medible:* Repositorio público en GitHub con README, guías y wiki *Alcanzable:* Siguiendo estándares de documentación open-source *Relevante:* Cumple con el objetivo de contribuir a la comunidad *Temporal:* Para la fase final del proyecto   |

 

### **Tabla Comparativa de Soluciones Similares** {#tabla-comparativa-de-soluciones-similares}

### 

|  | Trello | Taiga | Wekan | Asana |
| :---- | :---- | :---- | :---- | :---- |
| **Características Principales** | Kanban-style boards, checklists, Power-Ups, automatización con Butler, campos personalizados, integraciones | Open-source, enfoque ágil, gestión de tareas, seguimiento de errores, seguimiento de tiempo, informes, soporta Scrum, Kanban y Scrumban | Open-source, gestión de tareas estilo Kanban, funcionalidad de arrastrar y soltar, filtrado de tareas, swimlanes, seguimiento de actividad | Gestión de proyectos basada en la nube, asignación de tareas, vistas de proyecto (lista, tablero, línea de tiempo), características de colaboración, integraciones |
| **Ventajas** | Fácil de usar, asequible, flexible | Gratis y open-source, personalizable, adecuado para startups y empresas, soporte de comunidad activa | Gratis y open-source, personalizable, soporta entornos multi-usuario con permisos basados en roles | Amigable para el usuario, plan gratuito robusto para equipos pequeños, bueno para la gestión de tareas y colaboración |
| **Desventajas** | Carece de características avanzadas como gráficos de Gantt, seguimiento de tiempo y herramientas de informe completas | Carece de algunas integraciones y herramientas avanzadas de gestión de proyectos en comparación con competidores como Jira. Características de informe rudimentarias | Puede requerir más experiencia técnica para la configuración, menos integraciones con servicios de terceros, problemas de rendimiento con tableros más grandes | Puede ser costoso para equipos más grandes, carece de algunas características avanzadas como informes y análisis completos |
| **Precios/Costos** | Plan gratuito disponible. Versión Business Class cuesta $25 por mes. Plan Standard cuesta $5 por usuario por mes con facturación anual. Planes Premium y Enterprise comienzan en $10 y $17.50 por usuario por mes, respectivamente. | Gratis para la versión básica. Plan Premium cuesta $7 por mes por usuario para proyectos privados ilimitados. | Gratis y open-source | Plan gratuito disponible. Plan Starter cuesta $10.99 por usuario por mes. Características premium comienzan en $13.49 por usuario por mes. |
| **Diferenciadores de Openflow** | Naturaleza abierta y diseño moderno y responsivo de Openflow | Naturaleza abierta y diseño moderno y responsivo de Openflow | Naturaleza abierta y diseño moderno y responsivo de Openflow | Naturaleza abierta y diseño moderno y responsivo de Openflow |

Reservados todos los derechos Fundación Instituto Profesional Duoc UC. No se permite copiar, reproducir, reeditar, descargar, publicar, emitir, difundir, de forma total o parcial la presente obra, ni su incorporación a un sistema informático, ni su transmisión en cualquier forma o por cualquier medio (electrónico, mecánico, fotocopia, grabación u otros) sin autorización previa y por escrito de Fundación Instituto Profesional Duoc UC La infracción de dichos derechos puede constituir un delito contra la propiedad intelectual.   
