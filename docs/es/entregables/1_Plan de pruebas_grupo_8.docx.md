**![][image1]**

**Plan de Pruebas de Software**  
**OpenFlow**  
***Fecha***   
 **2025-11-02**

**Tabla de contenido**

Información del Proyecto	[3](#información-del-proyecto)

Aprobaciones	[3](#aprobaciones)

Resumen Ejecutivo	[3](#resumen-ejecutivo )

Alcance de las Pruebas	[4](#alcance-de-las-pruebas)

Elementos de Pruebas	[4](#elementos-de-pruebas)

Funcionalidades a No Probar	[4](#funcionalidades-a-no-probar )

Enfoque de Pruebas (Estrategia)	[4](#enfoque-de-pruebas-\(estrategia\) )

Criterios de Aceptación o Rechazo	[5](#criterios-de-aceptación-o-rechazo)

Criterios de Aceptación o Rechazo	[5](#criterios-de-aceptación-o-rechazo )

Criterios de Suspensión	[5](#criterios-de-suspensión )

Criterios de Reanudación	[5](#criterios-de-reanudación)

Entregables	[6](#entregables )

Recursos	[6](#recursos)

Requerimientos de Entornos – Hardware	[6](# requerimientos-de-entornos-–-hardware )

Requerimientos de Entornos – Software	[7](#requerimientos-de-entornos-–-software )

Herramientas de Pruebas Requeridas	[8](#herramientas-de-pruebas-requeridas )

Personal	[9](#personal)

Planificación y Organización	[10](#planificación-y-organización)

Procedimientos para las Pruebas	[10](#procedimientos-para-las-pruebas)

Matriz de Responsabilidades	[12](#matriz-de-responsabilidades)

Cronograma	[12](#cronograma)

Premisas	[12](#premisas)

# **Información del Proyecto** {#información-del-proyecto}

| Empresa / Organización | Openflow |
| :---- | :---- |
| Proyecto | Openflow |
| Fecha de preparación | 2025-11-02 |
| Cliente | Usuarios finales de Openflow |
| Patrocinador principal | Alonso Esteban Castillo Pizarro |
| Gerente / Líder de Proyecto | Rodrigo Escala |
| Gerente / Líder de Pruebas de Software | Diego Barros |

# **Aprobaciones** {#aprobaciones}

| Nombre y Apellido | Cargo | Departamento u Organización | Fecha | Firma |
| :---: | :---: | :---: | :---: | :---: |
| **Rodrigo Escala** | **Líder de Proyecto** | **Openflow** | **2025-11-02** |  |
|   |  |  |  |  |
|   |  |  |  |  |
|   |  |  |  |  |

# **Resumen Ejecutivo ** {#resumen-ejecutivo }

Este plan de pruebas describe el enfoque y los procedimientos para garantizar la calidad del software Openflow. El objetivo principal es validar que el sistema cumpla con los requisitos funcionales y no funcionales, asegurando una experiencia de usuario satisfactoria. Este plan cubre aspectos generales del proceso de pruebas y se centra en las áreas críticas del sistema.

# **Alcance de las Pruebas** {#alcance-de-las-pruebas}

## **Elementos de Pruebas** {#elementos-de-pruebas}

**Los elementos de pruebas incluyen:**

* Interfaz de Usuario: Pruebas de usabilidad y funcionalidad de la interfaz de usuario.  
* Autenticación y Autorización: Pruebas de inicio de sesión, registro y permisos de usuario.  
* Gestión de Tableros: Creación, edición y eliminación de tableros.  
* Gestión de Tareas: Creación, edición, movimiento y eliminación de tareas.  
* APIs: Pruebas de las APIs utilizadas para la comunicación entre el frontend y el backend.  
* Integración con Azure AD: Pruebas de autenticación y autorización, incluyendo escenarios de inicio de sesión, registro, recuperación de contraseña y gestión de permisos de usuario.  
* Pruebas de Infraestructura: Validación de la contenerización con Podman, incluyendo despliegue, escalado y comunicación entre contenedores.

**Funcionalidades a No Probar **  
Las siguientes funcionalidades no serán probadas en esta fase:

* Integración con terceros: Integración con otras aplicaciones o servicios externos.  
* Funcionalidades avanzadas de reporting: Generación de informes avanzados y análisis de datos.

## **Enfoque de Pruebas (Estrategia) ** {#enfoque-de-pruebas-(estrategia) }

La estrategia de pruebas para Openflow incluye los siguientes tipos de pruebas:

* Pruebas Funcionales: Verificación de procesos como el registro de usuario, la creación de tableros y tareas, y la autenticación.  
* Pruebas de Desempeño: Evaluación de tiempos de carga y rendimiento bajo diferentes condiciones de tráfico.  
* Pruebas de Interfaces: Verificación de la integración entre el frontend y el backend.  
* Pruebas de Usabilidad: Evaluación de la facilidad de uso y la experiencia del usuario.  
* Pruebas de Compatibilidad: Verificación del correcto funcionamiento de la interfaz de usuario en diferentes navegadores (Chrome, Firefox, Edge, Safari) y dispositivos (desktop, tablet, móvil).

# **Criterios de Aceptación o Rechazo** {#criterios-de-aceptación-o-rechazo}

## **Criterios de Aceptación o Rechazo ** {#criterios-de-aceptación-o-rechazo }

* Todas las pruebas unitarias deben pasar.  
* Al menos el 80% de las pruebas de integración deben pasar.  
* El sistema debe manejar al menos 100 usuarios concurrentes sin perder rendimiento.  
* La interfaz de usuario debe ser intuitiva y fácil de usar para los usuarios finales.


## **Criterios de Suspensión ** {#criterios-de-suspensión }

## Las pruebas se suspenderán si:

* ## Se encuentran defectos críticos que impidan la ejecución de más pruebas.

* ## Se alcanza un porcentaje específico de casos fallidos (más del 20% de las pruebas fallan).

## 

## 

## **Criterios de Reanudación** {#criterios-de-reanudación}

* Los defectos críticos hayan sido corregidos.  
* Se hayan implementado las correcciones necesarias para los casos de prueba fallidos.

# **Entregables ** {#entregables }

Los entregables incluyen:

* Documento del Plan de Pruebas.  
* Casos de Prueba.  
* Especificaciones de Diseño de Casos.  
* Registros de Errores (logs).  
* Reportes de Incidencias.  
* Evidencias de Pruebas.  
* Reportes generados por herramientas de pruebas.

# **Recursos** {#recursos}

## ** Requerimientos de Entornos – Hardware ** {# requerimientos-de-entornos-–-hardware }

* Servidores de Aplicación: Servidor con capacidad de procesamiento adecuada para ejecutar la aplicación.  
* Bases de Datos: Requerimientos de hardware y software para las bases de datos utilizadas en las pruebas.  
* Equipos de PC para los Testers: Equipos con procesadores, memoria RAM y almacenamiento adecuados.  
* Conectividad a la Red: Configuraciones de red necesarias para acceder a las plataformas y servicios.

## **Requerimientos de Entornos – Software ** {#requerimientos-de-entornos-–-software }

* Sistemas de Pruebas: Acceso a los sistemas o plataformas que serán evaluados.  
* Bases de Datos: Acceso a las bases de datos utilizadas en las pruebas.  
* Herramientas de Pruebas: Instalación de software especializado para realizar las pruebas.  
* Software de Seguimiento de Incidencias: Acceso a plataformas de gestión de incidencias y bugs.  
* Sistemas de Control de Versiones: Herramientas de gestión de código fuente.  
* Software en Equipos de los Testers: Instalación de herramientas adicionales necesarias para los testers.

## **Herramientas de Pruebas Requeridas ** {#herramientas-de-pruebas-requeridas }

Herramientas de Automatización de Pruebas:

*   
* Selenium: Para la automatización de pruebas de aplicaciones web.  
* JUnit/TestNG: Para pruebas unitarias en aplicaciones Java.  
* Appium: Para la automatización de pruebas en aplicaciones móviles.  
* Software de Gestión de Pruebas:  
*   
* TestRail: Para la gestión de pruebas.  
* Quality Center (ALM): Para la gestión de pruebas, casos de prueba, defectos e informes.  
* Herramientas de Pruebas de Desempeño:  
*   
* JMeter: Para pruebas de carga y rendimiento de aplicaciones web.  
* LoadRunner: Para pruebas de carga y estrés.  
* Herramientas de Pruebas de Seguridad:  
*   
* OWASP ZAP: Para encontrar vulnerabilidades en aplicaciones web.  
* Burp Suite: Para pruebas de seguridad y análisis de vulnerabilidades

## **Personal** {#personal}

* Líder de Pruebas (1): Responsable de la planificación, supervisión y gestión general del proceso de pruebas.  
* Analistas de Pruebas (Testers) (2): Encargados de diseñar, ejecutar y documentar los casos de prueba.  
* Especialistas en Automatización de Pruebas (1): Encargados de la creación y mantenimiento de scripts de automatización.  
* Especialista en Pruebas de Seguridad (1): Encargado de realizar pruebas de seguridad.  
* Especialista en Pruebas de Desempeño (1): Responsable de realizar pruebas de carga, estrés y rendimiento.  
* Administrador de Base de Datos (1): Encargado de la gestión de las bases de datos de prueba.  
* Ingeniero de Integración (1): Encargado de las pruebas de integración.  
* Coordinador de Pruebas (1): Responsable de la logística y coordinación de las pruebas.  
* Documentador de Pruebas (1): Encargado de generar y mantener la documentación de pruebas.  
* Tester de Usabilidad (1): Encargado de realizar pruebas de usabilidad.

# **Planificación y Organización** {#planificación-y-organización}

## **Procedimientos para las Pruebas** {#procedimientos-para-las-pruebas}

* Metodología de Pruebas Ágiles: Las pruebas se realizarán de forma continua durante el ciclo de vida del desarrollo.  
* Ciclo de Vida del Caso de Prueba: Diseño, ejecución, registro de defectos y reejecución de casos de prueba.  
* Pruebas de Caja Negra: Enfoque en evaluar las funcionalidades del software sin necesidad de conocer su estructura interna.  
* Pruebas de Caja Blanca: Pruebas que requieren acceso al código fuente para evaluar la estructura interna del software.  
* Pruebas de Regresión: Pruebas para asegurarse de que los cambios en el código no hayan afectado negativamente las fu ncionalidades existentes.  
* Pruebas de Desempeño: Pruebas para medir la capacidad del software para manejar diferentes niveles de carga y tráfico.  
* Pruebas de Usabilidad: Pruebas con usuarios reales para evaluar la experiencia del usuario final.  
* Pruebas de Seguridad: Pruebas para identificar vulnerabilidades de seguridad dentro de la aplicación.  
* Pruebas de Compatibilidad: Pruebas para verificar que el software funcione correctamente en diferentes plataformas y sistemas operativos.  
* Pruebas de Integración: Pruebas para validar la interacción entre diferentes módulos o componentes del software.  
* Pruebas de Aceptación del Usuario (UAT): Pruebas realizadas al final del ciclo de pruebas para validar que el software cumpla con los requisitos y expectativas del usuario final.

## **Casos de Prueba Principales**

### **Módulo de Autenticación (ID: AUTH-01 a AUTH-05)**

| ID | Descripción | Pasos | Datos de Prueba | Resultado Esperado |
| :---- | :---- | :---- | :---- | :---- |
| AUTH-01 | Login exitoso | 1\. Ir a pantalla login  2\. Ingresar credenciales válidas 3\. Clic en "Iniciar sesión" | usuario: [test@user.com](mailto:test@user.com)  pass: Test1234\! | Redirige a dashboard principal |
| AUTH-02 | Login fallido (credenciales inválidas) | 1\. Ir a pantalla login  2\. Ingresar credenciales incorrectas 3\. Clic en "Iniciar sesión" | usuario: [invalid@test.com](mailto:invalid@test.com)  pass: wrongpass | Muestra mensaje de error |
| AUTH-03 | Recuperación de contraseña | 1\. Clic en "¿Olvidaste contraseña?"  2\. Ingresar email válido 3\. Clic en "Enviar" | email: [test@user.com](mailto:test@user.com) | Recibe email con enlace de recuperación |

### **Módulo de Tableros (ID: BOARD-01 a BOARD-05)**

| ID | Descripción | Pasos | Datos de Prueba | Resultado Esperado |
| :---- | :---- | :---- | :---- | :---- |
| BOARD-01 | Crear tablero | 1\. Clic en "Nuevo tablero"  2\. Completar formulario 3\. Clic en "Guardar" | Nombre: "Proyecto Final"  Descripción: "Tareas del sprint" | Tablero aparece en lista |
| BOARD-02 | Editar tablero | 1\. Seleccionar tablero  2\. Clic en "Editar" 3\. Modificar nombre 4\. Clic en "Guardar" | Nuevo nombre: "Proyecto Final v2" | Nombre actualizado correctamente |
| BOARD-03 | Eliminar tablero | 1\. Seleccionar tablero  2\. Clic en "Eliminar" 3\. Confirmar acción | \- | Tablero desaparece de lista |

### **Módulo de Tareas (ID: TASK-01 a TASK-05)**

| ID | Descripción | Pasos | Datos de Prueba | Resultado Esperado |
| :---- | :---- | :---- | :---- | :---- |
| TASK-01 | Crear tarea | 1\. Abrir tablero  2\. Clic en "Añadir tarea" 3\. Completar formulario 4\. Clic en "Guardar" | Título: "Implementar API"  Descripción: "Conectar con GitHub" | Tarea aparece en columna "Por hacer" |
| TASK-02 | Mover tarea entre columnas | 1\. Arrastrar tarea de "Por hacer" a "En progreso" | \- | Tarea aparece en nueva columna |

## **Matriz de Responsabilidades** {#matriz-de-responsabilidades}

| Rol | Responsabilidad |
| :---- | :---- |
| Líder de Pruebas | Planificación, supervisión y gestión general del proceso de pruebas. |
| Analistas de Pruebas | Diseño, ejecución y documentación de los casos de prueba. |
| Especialistas en Automatización de Pruebas | Creación y mantenimiento de scripts de automatización. |
| Especialista en Pruebas de Seguridad | Realización de pruebas de seguridad. |
| Especialista en Pruebas de Desempeño | Realización de pruebas de carga, estrés y rendimiento. |
| Administrador de Base de Datos | Gestión de las bases de datos de prueba. |
| Ingeniero de Integración | Pruebas de integración. |
| Coordinador de Pruebas | Logística y coordinación de las pruebas. |
| Documentador de Pruebas | Generación y mantenimiento de la documentación de pruebas. |
| Tester de Usabilidad | Realización de pruebas de usabilidad. |

 

## **Cronograma** {#cronograma}

El cronograma del plan de pruebas incluye las siguientes actividades y fechas estimadas:

| Actividad | Fecha de Inicio | Fecha de Fin |
| :---- | :---- | :---- |
| Planificación de Pruebas | 2025-11-02 | 2025-11-09 |
| Diseño de Casos de Prueba | 2025-11-10 | 2025-11-17 |
| Ejecución de Pruebas | 2025-11-18 | 2025-12-05 |
| Registro de Defectos | 2025-12-06 | 2025-12-12 |
| Reejecución de Pruebas | 2025-12-13 | 2025-12-20 |

## **Premisas** {#premisas}

* **Limitaciones de Tiempo**: Las pruebas deben completarse dentro del cronograma establecido.  
* **Disponibilidad de Recursos**: Los recursos necesarios estarán disponibles según lo previsto.  
* **Uso de Metodología de Pruebas**: Se seguirá un enfoque ágil para las pruebas de software.  
* **Uso de Herramientas de Pruebas**: Se utilizarán herramientas específicas para la gestión de pruebas, automatización, seguimiento de defectos y otras actividades relacionadas.  
* **Disponibilidad de Entornos de Prueba**: Los entornos de prueba estarán listos y configurados adecuadamente.  
* **Requerimientos de Datos de Prueba**: Los datos de prueba estarán disponibles y serán adecuados para simular escenarios reales.  
* **Capacitación y Habilidades del Equipo**: Los miembros del equipo de pruebas tienen la capacitación y habilidades necesarias.  
* **Alcance de las Pruebas**: El alcance de las pruebas está claramente definido.  
* **Gestión de Defectos**: Habrá un proceso definido para la identificación, clasificación y resolución de defectos.  
* **Coordinación y Comunicación del Equipo**: Habrá una comunicación clara y continua entre los miembros del equipo y los stakeholders.  
* **Riesgos y Contingencias**: Los riesgos identificados serán gestionados y habrá planes de contingencia.  
* **Aprobación y Validación**: Los stakeholders validarán y aprobarán los resultados de las pruebas.  
* **Integración de las Pruebas con el Desarrollo**: Las pruebas se llevarán a cabo en paralelo con el desarrollo.

 

# **Referencias** 

# Formato de respuesta basado en: PMO Informática:

# PMO Informática. (07 de enero 2025). Plantillas. PMO Informática. [https://www.pmoinformatica.com/p/plantillas-de-gerencia-de-proyectos.html](https://www.pmoinformatica.com/p/plantillas-de-gerencia-de-proyectos.html)

[image1]: <data:image/png;base64,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>