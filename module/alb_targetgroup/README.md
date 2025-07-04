# Módulo ALB Target Group

## 📋 Descripción

Este módulo crea Target Groups para el ALB y configura las reglas de enrutamiento basadas en patrones de ruta o encabezados de host. Los Target Groups definen dónde el ALB debe enviar el tráfico.

## 🎯 Recursos Creados

- `aws_lb_target_group`: Target Group para el servicio
- `aws_lb_listener_rule`: Regla de enrutamiento en el listener

## 📥 Variables de Entrada

| Variable | Descripción | Tipo | Requerido | Default |
|----------|-------------|------|-----------|---------|
| `name_prefix` | Prefijo para el nombre del target group | `string` | ✅ | - |
| `service_name` | Nombre del servicio (api, frontend, etc.) | `string` | ✅ | - |
| `vpc_id` | ID del VPC donde se crea el target group | `string` | ✅ | - |
| `container_port` | Puerto del contenedor al que dirigir el tráfico | `number` | ✅ | - |
| `listener_arn` | ARN del listener del ALB | `string` | ✅ | - |
| `rule_priority` | Prioridad de la regla (1-50000, menor = mayor prioridad) | `number` | ✅ | - |
| `path_patterns` | Lista de patrones de ruta para el enrutamiento | `list(string)` | ✅ | - |
| `host_headers` | Lista de encabezados de host para el enrutamiento | `list(string)` | ❌ | `[]` |
| `project_tags` | Tags a aplicar a los recursos | `map(string)` | ✅ | - |

## 📤 Outputs

| Output | Descripción | Tipo |
|--------|-------------|------|
| `target_group_arn` | ARN del target group creado | `string` |

## 💡 Ejemplo de Uso

### Enrutamiento por Path
```hcl
module "api_targetgroup" {
  source = "./module/alb_targetgroup"
  
  name_prefix    = "proyecto-dev"
  service_name   = "api"
  vpc_id         = "vpc-123456"
  container_port = 80
  listener_arn   = module.alb_listeners.http_listener_arn
  rule_priority  = 100
  path_patterns  = ["/api/*", "/v1/*"]
  project_tags   = local.common_tags
}
```

### Enrutamiento por Host
```hcl
module "admin_targetgroup" {
  source = "./module/alb_targetgroup"
  
  name_prefix    = "proyecto-dev"
  service_name   = "admin"
  vpc_id         = "vpc-123456"
  container_port = 3000
  listener_arn   = module.alb_listeners.https_listener_arn
  rule_priority  = 200
  path_patterns  = ["/*"]
  host_headers   = ["admin.example.com"]
  project_tags   = local.common_tags
}
```

## 🔍 Notas Importantes

- El nombre del target group será: `{name_prefix}-{service_name}-tg`
- Los health checks están configurados con valores por defecto optimizados
- La prioridad de las reglas debe ser única dentro del listener
- Las reglas se evalúan en orden de prioridad (menor número = mayor prioridad)
- Puedes combinar path_patterns y host_headers para reglas más específicas

## ⚕️ Configuración de Health Checks

Los health checks están preconfigurados con:
- **Path**: `/` 
- **Intervalo**: 30 segundos
- **Timeout**: 5 segundos
- **Healthy threshold**: 2 checks exitosos
- **Unhealthy threshold**: 2 checks fallidos
- **Matcher**: Códigos HTTP 200

## 🔗 Recursos Relacionados

- [AWS Target Groups](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-target-groups.html)
- [Listener Rules](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-listeners.html#rule-condition-types)