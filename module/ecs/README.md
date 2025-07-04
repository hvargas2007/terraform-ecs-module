# Módulo ECS Cluster

## 📋 Descripción

Este módulo crea un cluster de Amazon ECS (Elastic Container Service) que sirve como la infraestructura base para ejecutar servicios en contenedores usando AWS Fargate.

## 🎯 Recursos Creados

- `aws_ecs_cluster`: Cluster ECS con configuración opcional de Container Insights

## 📥 Variables de Entrada

| Variable | Descripción | Tipo | Requerido | Default |
|----------|-------------|------|-----------|---------|
| `name_prefix` | Prefijo para el nombre del cluster | `string` | ✅ | - |
| `project_tags` | Tags a aplicar al cluster | `map(string)` | ✅ | - |
| `uses_container_insights` | Habilitar Container Insights para monitoreo avanzado | `bool` | ✅ | - |

## 📤 Outputs

| Output | Descripción | Tipo |
|--------|-------------|------|
| `ecs_cluster_id` | ID/ARN del cluster ECS | `string` |
| `ecs_cluster_name` | Nombre del cluster ECS | `string` |

## 💡 Ejemplo de Uso

### Cluster Básico
```hcl
module "ecs" {
  source = "./module/ecs"
  
  name_prefix             = "mi-proyecto-dev"
  project_tags            = local.common_tags
  uses_container_insights = false
}
```

### Cluster con Container Insights
```hcl
module "ecs" {
  source = "./module/ecs"
  
  name_prefix             = "mi-proyecto-prod"
  project_tags            = local.common_tags
  uses_container_insights = true  # Monitoreo avanzado
}
```

## 🔍 Notas Importantes

- El nombre del cluster será: `{name_prefix}`
- Container Insights proporciona métricas adicionales pero tiene costo adicional
- El cluster por sí solo no consume recursos, solo es un agrupador lógico
- Los servicios Fargate se ejecutan sin necesidad de administrar instancias EC2

## 📊 Container Insights

Cuando está habilitado, Container Insights proporciona:
- Métricas a nivel de cluster, servicio y tarea
- Logs centralizados
- Dashboards automáticos en CloudWatch
- Alertas basadas en métricas de contenedores

**Nota**: Container Insights tiene costos adicionales por las métricas y logs generados.

## 🔗 Recursos Relacionados

- [Amazon ECS Clusters](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/clusters.html)
- [Container Insights](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/ContainerInsights.html)
- [ECS Fargate](https://docs.aws.amazon.com/AmazonECS/latest/userguide/what-is-fargate.html)