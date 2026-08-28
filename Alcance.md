# Gestión Visual de Stands para Eventos

Aplicación móvil para la organización y gestión integral de eventos con stands. El sistema está conformado por:

- **App móvil para el organizador** (interfaz principal de trabajo en el terreno)
- **Servidor y base de datos** (gestión y sincronización de información)
- **Asistente inteligente con IA** (apoyo en consultas y propuestas de distribución)

> **El organizador controla y ajusta la distribución del evento directamente desde un plano interactivo mientras recorre el salón. El asistente de IA responde dudas al instante y sugiere optimizaciones de espacio, dejando siempre la decisión final en manos del organizador.**

## Fuera de alcance

- Venta de entradas y procesamiento de pagos.
- Comercialización o alquiler de stands.
- Gestión de proveedores, personal o logística del recinto.
- Difusión, publicidad o integración con redes sociales.
- Herramientas de diseño arquitectónico o planos profesionales.
- Automatización o toma de decisiones autónoma por parte de la IA.

## Épicas Principales

1. **Gestión de eventos**: Creación y administración de los datos generales del evento.
2. **Gestión de stands**: Creación, asignación, liberación y movimiento de espacios.
3. **Plano interactivo**: Visualización en tiempo real de la distribución del recinto.
4. **Gestión de expositores**: Registro y ubicación rápida de participantes.
5. **Asistente inteligente**: Consultas en lenguaje natural y sugerencias de reorganización.
6. **Almacenamiento y sincronización de datos**: Resguardo y consistencia de la información.

## Historias de Usuario

### Gestión de eventos

| ID | Historia de usuario | Prioridad |
| --- | --- | --- |
| EVT01 | Como organizador, quiero crear un nuevo evento con sus datos básicos, para empezar a planificar su estructura y distribución. | Alta |
| EVT02 | Como organizador, quiero ver el resumen del evento, para revisar su estado actual y configuración en cualquier momento. | Media |

### Gestión de stands

| ID | Historia de usuario | Prioridad |
| --- | --- | --- |
| STA01 | Como organizador, quiero agregar un nuevo stand al plano, para definir un espacio disponible para un expositor. | Alta |
| STA02 | Como organizador, quiero tocar un stand en el plano para ver sus detalles, conociendo de inmediato su ubicación, estado y quién lo ocupa. | Alta |
| STA03 | Como organizador, quiero asignar un expositor a un stand libre, para registrar oficialmente la ocupación de ese espacio. | Alta |
| STA04 | Como organizador, quiero liberar un stand ocupado, para dejar el espacio disponible para otra persona o marca. | Media |
| STA05 | Como organizador, quiero arrastrar y mover un stand en el plano, para adaptar la distribución según las necesidades del momento. | Media |

### Gestión de expositores

| ID | Historia de usuario | Prioridad |
| --- | --- | --- |
| EXP01 | Como organizador, quiero registrar los datos de un expositor, para poder vincularlo a un stand dentro del evento. | Alta |
| EXP02 | Como organizador, quiero buscar la ubicación de un expositor, para saber exactamente en qué stand se encuentra. | Media |

### Plano interactivo

| ID | Historia de usuario | Prioridad |
| --- | --- | --- |
| PLA01 | Como organizador, quiero ver la distribución completa de los stands en un mapa visual, para entender la organización general del recinto de un vistazo. | Alta |
| PLA02 | Como organizador, quiero identificar fácilmente qué stands están ocupados y cuáles libres (mediante colores o indicadores visuales), para tomar decisiones rápidamente. | Alta |
| PLA03 | Como organizador, quiero hacer cambios en la distribución desde mi teléfono mientras camino por el lugar, para actualizar el mapa en tiempo real. | Alta |

### Asistente inteligente

| ID | Historia de usuario | Prioridad |
| --- | --- | --- |
| IA01 | Como organizador, quiero hacerle preguntas al asistente en lenguaje natural, para obtener respuestas rápidas sin buscar manualmente en menús. | Media |
| IA02 | Como organizador, quiero preguntarle al asistente dónde está un expositor, para ubicarlo rápidamente en el mapa. | Media |
| IA03 | Como organizador, quiero pedirle al asistente propuestas para reorganizar los stands, para optimizar el espacio de forma inteligente ante un imprevisto. | Media |
| IA04 | Como organizador, quiero revisar y confirmar cualquier sugerencia de la IA antes de que se aplique, para mantener el control total del evento. | Alta |

## ¿Por qué una app móvil?

El organizador necesita trabajar "en el terreno". La app móvil le permite consultar el plano, hacer ajustes al instante y orientar a los expositores mientras camina por el salón, sin depender de una computadora ni de planos de papel que quedan desactualizados rápidamente.