

**Plan de Gestión de Calidad**  
**OpenFlow**

**Nombre de la empresa**  
**OpenFlow**

**Dirección**

**Fecha 2025-11-03**

**Introducción**

El propósito de este documento es describir el plan de gestión de calidad para el proyecto Openflow. Este plan tiene como objetivo asegurar que el proyecto cumpla con los estándares de calidad establecidos y que se entregue un producto que satisfaga las necesidades y expectativas de los usuarios finales.

**Objetivo del Plan de Gestión de Calidad**

El objetivo del plan de gestión de calidad es garantizar que el proyecto Openflow cumpla con los más altos estándares de calidad en todas las etapas de su desarrollo. Esto incluye la planificación, diseño, desarrollo, pruebas y despliegue del software.

**Tiempos de entrega para paquetes de trabajo (Procesos / Entregables del proyecto sujetos a revisión de calidad)**

**Los siguientes entregables y procesos del proyecto estarán sujetos a revisión de calidad:**

| Entregable / Proceso | Fecha de Entrega |
| :---- | :---- |
| Diseño de la Arquitectura | 2025-11-15 |
| Desarrollo del Frontend | 2025-12-01 |
| Desarrollo del Backend | 2025-12-15 |
| Pruebas de Integración | 2025-12-22 |
| Pruebas de Usabilidad | 2025-12-29 |
| Despliegue Inicial | 2026-01-05 |

**Asignación de responsables del seguimiento de la calidad** 

| Nombre | Rol | Responsabilidad |
| :---- | :---- | :---- |
| Diego Barros | Líder Técnico | Asegurar que los estándares de calidad se cumplan en todas las etapas del desarrollo. |
| Rodrigo Escala | Gerente de Proyecto | Supervisar el cumplimiento de los estándares de calidad y aprobar los entregables. |
| Alonso Esteban Castillo Pizarro | Stakeholder | Proporcionar retroalimentación y orientación sobre los estándares de calidad. |

**Estándares de Calidad**

Los estándares de calidad para el proyecto Openflow incluyen:

| Entregable | Criterios de Aceptación | Responsable | Fecha Límite |
| :---- | :---- | :---- | :---- |
| Diseño de Arquitectura | Aprobación del documento por stakeholders  Diagramas actualizados en Draw.io Revisión de coherencia con requisitos | Rodrigo Escala | 2025-11-15 |
| Desarrollo Frontend | 90% de funcionalidades implementadas  Compatibilidad con Chrome/Firefox Sin errores críticos en consola | Diego Barros | 2025-12-01 |
| Desarrollo Backend | 80% de cobertura de pruebas unitarias  Documentación API actualizada Integración exitosa con Azure AD | Diego Barros | 2025-12-15 |
| Pruebas de Integración | 90% de casos de prueba pasados  Informes de pruebas documentados Sin regresiones en funcionalidades clave | Equipo | 2025-12-22 |
| Pruebas de Usabilidad | 80% de satisfacción en encuestas  Mínimo 5 usuarios testeando Informes de usabilidad documentados | Diego Barros | 2025-12-29 |
| Despliegue Inicial | Aplicación accesible en entorno de producción  Documentación de despliegue completa Verificación de seguridad básica | Rodrigo Escala | 2026-01-05 |

## **Atributos de Calidad**

### **Estándar para Pruebas Unitarias**

- **Cobertura mínima esperada:** 70% de cobertura de código  
- **Herramientas:** JUnit 5 para Java, Jest para React  
- **Requisitos:**  
  - Pruebas para todas las funciones públicas  
  - Casos de prueba para escenarios normales y de error  
  - Documentación de pruebas en formato README.md  
  - Integración con pipeline de CI/CD

**Atributos de Calidad**

**Indicadores de Calidad** 

Los atributos de calidad que se considerarán en el proyecto Openflow son:

| Indicador | Descripción | Atributo |
| :---- | :---- | :---- |
| Índice de Desempeño del Cronograma | Cumplir con los tiempos y recursos definidos en el cronograma. | Cumplimiento del Cronograma |
| Número de Defectos | Minimizar el número de defectos en el software. | Calidad del Código |
| Tasa de Satisfacción del Cliente | Medir la satisfacción del cliente con el producto final. | Satisfacción del Cliente |
| Tiempo de Respuesta de APIs | Medir el tiempo de respuesta de las APIs en la integración entre AWS, Azure y Oracle. | Rendimiento |
| Éxito en Autenticación con Azure AD | Porcentaje de intentos de autenticación exitosos. | Seguridad |
| Índice de Indexación en Motores de Búsqueda | Porcentaje de tableros públicos indexados correctamente en Google y otros motores. | Visibilidad |

**Instrumento de medición de Calidad**

| Instrumento | Descripción | Estándar | Atributos | Indicador |
| :---- | :---- | :---- | :---- | :---- |
| Revisión de Código | Revisión manual y automatizada del código para asegurar su calidad. | Calidad del Código | Funcionalidad, Seguridad | Número de Defectos |
| Pruebas de Usabilidad | Evaluación de la facilidad de uso del software por parte de los usuarios finales. | Satisfacción del Cliente | Usabilidad | Tasa de Satisfacción del Cliente |
| Pruebas de Rendimiento | Evaluación del rendimiento del software bajo diferentes condiciones de carga. | Rendimiento | Rendimiento | Tiempo de Respuesta |

**Mediciones del Control de Calidad**

Las mediciones del control de calidad se registrarán de la siguiente manera:

| Fecha | Proceso / Producto Medido | Valor Requerido | Valor Obtenido | ¿Es Aceptable? | Recomendación | Fecha de Resolución |
| :---- | :---- | :---- | :---- | :---- | :---- | :---- |
| 2025-11-15 | Diseño de la Arquitectura | Cumplimiento del 100% de los requisitos |  |  |  |  |
| 2025-12-01 | Desarrollo del Frontend | Cumplimiento del 100% de los requisitos |  |  |  |  |
| 2025-12-15 | Desarrollo del Backend | Cumplimiento del 100% de los requisitos |  |  |  |  |
| 2025-12-22 | Pruebas de Integración | Cumplimiento del 100% de los requisitos |  |  |  |  |
| 2025-12-29 | Pruebas de Usabilidad | Tasa de satisfacción del 90% |  |  |  |  |
| 2026-01-05 | Despliegue Inicial | Cumplimiento del 100% de los requisitos |  |  |  |  |

**Aceptación del patrocinador del proyecto**

Aprobado por: 

| Nombre | Firma | Fecha |
| :---- | :---- | :---- |
| Rodrigo Escala |  | 2025-11-02 |
| Alonso Esteban Castillo Pizarro |  | 2025-11-02 |

# **Referencias** 

# Formato de respuesta basado en: PMO Informática:

# PMO Informática. (07 de enero 2025). Plantillas. PMO Informática. [https://www.pmoinformatica.com/p/plantillas-de-gerencia-de-proyectos.html](https://www.pmoinformatica.com/p/plantillas-de-gerencia-de-proyectos.html)

