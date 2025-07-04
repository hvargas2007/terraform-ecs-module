# Módulo ALB (Application Load Balancer)

## 📋 Descripción

Este módulo crea un Application Load Balancer (ALB) en AWS. El ALB es responsable de distribuir el tráfico entrante entre múltiples targets (servicios ECS) basándose en reglas definidas.

## 🎯 Recursos Creados

- `aws_lb`: Application Load Balancer

## 📥 Variables de Entrada

| Variable | Descripción | Tipo | Requerido | Default |
|----------|-------------|------|-----------|---------|
| `name_prefix` | Prefijo para el nombre del ALB | `string` | ✅ | - |
| `project_tags` | Tags a aplicar a todos los recursos | `map(string)` | ✅ | - |
| `subnets` | Lista de IDs de subnets donde se desplegará el ALB (mínimo 2 en diferentes AZs) | `list(string)` | ✅ | - |
| `security_groups` | Lista de IDs de security groups a asociar con el ALB | `list(string)` | ✅ | - |
| `internal` | Si el ALB debe ser interno (true) o público (false) | `bool` | ❌ | `false` |
| `enable_deletion_protection` | Habilitar protección contra eliminación accidental | `bool` | ❌ | `false` |

## 📤 Outputs

| Output | Descripción | Tipo |
|--------|-------------|------|
| `alb_arn` | ARN del Application Load Balancer | `string` |
| `alb_dns_name` | Nombre DNS del ALB para acceder a las aplicaciones | `string` |
| `alb_zone_id` | ID de la zona hospedada del ALB | `string` |

## 💡 Ejemplo de Uso

```hcl
module "alb" {
  source = "./module/alb"
  
  name_prefix     = "mi-proyecto-dev"
  project_tags    = {
    Environment = "dev"
    Project     = "mi-proyecto"
  }
  subnets         = ["subnet-abc123", "subnet-def456"]
  security_groups = [module.alb_security_group.sg_id]
  internal        = false
  enable_deletion_protection = false
}
```

## 🔍 Notas Importantes

- El ALB requiere al menos 2 subnets en diferentes zonas de disponibilidad
- Para un ALB público, las subnets deben tener acceso a Internet (Internet Gateway)
- Para un ALB interno, puede usar subnets privadas
- El nombre del ALB será: `{name_prefix}-alb`

## 🔗 Recursos Relacionados

- [Documentación AWS ALB](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/)
- [Terraform aws_lb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb)