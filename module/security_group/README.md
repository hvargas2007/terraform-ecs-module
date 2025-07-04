# Módulo Security Group

## 📋 Descripción

Este módulo crea y gestiona Security Groups de AWS, que actúan como firewalls virtuales para controlar el tráfico entrante y saliente de los recursos. Es un módulo flexible que permite definir reglas dinámicas tanto para tráfico ingress como egress.

## 🎯 Recursos Creados

- `aws_security_group`: Security Group con reglas dinámicas

## 📥 Variables de Entrada

| Variable | Descripción | Tipo | Requerido | Default |
|----------|-------------|------|-----------|---------|
| `name_prefix` | Prefijo para el nombre del security group | `string` | ✅ | - |
| `project_tags` | Tags a aplicar al security group | `map(string)` | ✅ | - |
| `vpc_id` | ID del VPC donde crear el security group | `string` | ✅ | - |
| `ingress_rules` | Lista de reglas de entrada | `list(object)` | ✅ | - |
| `egress_rules` | Lista de reglas de salida | `list(object)` | ✅ | - |

### Estructura de las Reglas

```hcl
ingress_rules = [
  {
    description     = string              # Descripción de la regla
    from_port       = number              # Puerto inicial
    to_port         = number              # Puerto final
    protocol        = string              # Protocolo (tcp, udp, icmp, -1)
    cidr_blocks     = list(string)        # Lista de bloques CIDR (opcional)
    security_groups = list(string)        # Lista de IDs de security groups (opcional)
  }
]
```

## 📤 Outputs

| Output | Descripción | Tipo |
|--------|-------------|------|
| `ecs_sg_id` | ID del security group creado | `string` |

## 💡 Ejemplo de Uso

### Security Group para ALB (Internet-facing)
```hcl
module "alb_security_group" {
  source = "./module/security_group"
  
  name_prefix  = "proyecto-dev-alb"
  project_tags = local.common_tags
  vpc_id       = var.vpc_id
  
  ingress_rules = [
    {
      description = "Allow HTTP from anywhere"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "Allow HTTPS from anywhere"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
  
  egress_rules = [
    {
      description = "Allow all outbound traffic"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}
```

### Security Group para ECS (Restringido)
```hcl
module "ecs_security_group" {
  source = "./module/security_group"
  
  name_prefix  = "proyecto-dev-ecs"
  project_tags = local.common_tags
  vpc_id       = var.vpc_id
  
  ingress_rules = [
    {
      description     = "Allow traffic from ALB on port 80"
      from_port       = 80
      to_port         = 80
      protocol        = "tcp"
      security_groups = [module.alb_security_group.ecs_sg_id]
    },
    {
      description = "Allow traffic from VPC for health checks"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/16"]
    }
  ]
  
  egress_rules = [
    {
      description = "Allow HTTPS to external APIs"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "Allow PostgreSQL to RDS"
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      cidr_blocks = ["10.0.1.0/24"]  # Subnet de RDS
    }
  ]
}
```

## 🔍 Notas Importantes

- El nombre del security group será: `{name_prefix}-ecs-sg`
- Puedes usar `cidr_blocks` y `security_groups` en la misma regla
- Para permitir todo el tráfico, usa `protocol = "-1"` con `from_port = 0` y `to_port = 0`
- Las reglas se evalúan como "permitir" - todo lo no especificado está denegado

## 🔒 Buenas Prácticas de Seguridad

1. **Principio de menor privilegio**: Solo abre los puertos necesarios
2. **Usar Security Groups como fuente**: Prefiere referenciar otros SGs en lugar de CIDRs
3. **Documentar reglas**: Siempre incluye descripciones claras
4. **Separar por función**: Crea SGs específicos para cada tipo de recurso
5. **Revisar regularmente**: Audita las reglas periódicamente

## 🌐 Protocolos Comunes

| Protocolo | Valor | Uso |
|-----------|-------|-----|
| TCP | `"tcp"` | HTTP, HTTPS, SSH, bases de datos |
| UDP | `"udp"` | DNS, VPN |
| ICMP | `"icmp"` | Ping, traceroute |
| Todos | `"-1"` | Permitir todo (usar con cuidado) |

## 🔗 Recursos Relacionados

- [AWS Security Groups](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_SecurityGroups.html)
- [Security Group Rules](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/security-group-rules.html)
- [Best Practices](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-security-best-practices.html)