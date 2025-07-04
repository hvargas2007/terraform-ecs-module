# Módulo Auto Scaling

## 📋 Descripción

Este módulo configura el auto scaling para servicios ECS, permitiendo que el número de tareas se ajuste automáticamente basándose en métricas de CPU y memoria. Incluye tanto el escalado hacia arriba como hacia abajo.

## 🎯 Recursos Creados

- `aws_appautoscaling_target`: Define el target de auto scaling
- `aws_appautoscaling_policy`: Política de escalado por CPU
- `aws_appautoscaling_policy`: Política de escalado por memoria

## 📥 Variables de Entrada

| Variable | Descripción | Tipo | Requerido | Default |
|----------|-------------|------|-----------|---------|
| `service_name` | Nombre del servicio ECS | `string` | ✅ | - |
| `cluster_name` | Nombre del cluster ECS | `string` | ✅ | - |
| `min_capacity` | Número mínimo de tareas | `number` | ✅ | - |
| `max_capacity` | Número máximo de tareas | `number` | ✅ | - |
| `cpu_target_value` | Porcentaje objetivo de utilización de CPU | `number` | ✅ | - |
| `memory_target_value` | Porcentaje objetivo de utilización de memoria | `number` | ✅ | - |

## 📤 Outputs

Este módulo no tiene outputs.

## 💡 Ejemplo de Uso

### Configuración Básica
```hcl
module "api_autoscaling" {
  source = "./module/autoscaling"
  
  service_name        = "api-service"
  cluster_name        = "mi-cluster-dev"
  min_capacity        = 1
  max_capacity        = 10
  cpu_target_value    = 70
  memory_target_value = 80
}
```

### Configuración para Alta Disponibilidad
```hcl
module "frontend_autoscaling" {
  source = "./module/autoscaling"
  
  service_name        = "frontend-service"
  cluster_name        = "mi-cluster-prod"
  min_capacity        = 3      # Mínimo 3 para HA
  max_capacity        = 20     # Permitir mayor escalado
  cpu_target_value    = 60     # Escalar más temprano
  memory_target_value = 70     # Escalar más temprano
}
```

## 🔍 Notas Importantes

- **Escalado hacia arriba (scale out)**: 
  - Cooldown: 60 segundos
  - Se activa cuando CPU o memoria superan el objetivo
  
- **Escalado hacia abajo (scale in)**:
  - Cooldown: 300 segundos (5 minutos)
  - Se activa cuando CPU y memoria están bajo el objetivo
  - Más conservador para evitar flapping

- Las métricas se evalúan cada minuto
- El servicio nunca tendrá menos de `min_capacity` tareas
- El servicio nunca tendrá más de `max_capacity` tareas

## 📊 Recomendaciones de Configuración

| Ambiente | Min | Max | CPU Target | Memory Target |
|----------|-----|-----|------------|---------------|
| Dev | 1 | 4 | 70% | 80% |
| Staging | 2 | 8 | 70% | 80% |
| Prod | 3 | 20+ | 60% | 70% |

## ⚡ Métricas Monitoreadas

- **ECSServiceAverageCPUUtilization**: Promedio de CPU usado por todas las tareas
- **ECSServiceAverageMemoryUtilization**: Promedio de memoria usada por todas las tareas

## 🔗 Recursos Relacionados

- [AWS Auto Scaling for ECS](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/service-auto-scaling.html)
- [Target Tracking Scaling Policies](https://docs.aws.amazon.com/autoscaling/application/userguide/application-auto-scaling-target-tracking.html)