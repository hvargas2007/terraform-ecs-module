# Módulo Parameter Store

## 📋 Descripción

Este módulo gestiona parámetros seguros en AWS Systems Manager Parameter Store. Es ideal para almacenar configuraciones sensibles como URLs de base de datos, API keys, y otros secretos que las aplicaciones necesitan en tiempo de ejecución.

## 🎯 Recursos Creados

- `aws_ssm_parameter`: Parámetros seguros en Parameter Store (uno por cada entrada)

## 📥 Variables de Entrada

| Variable | Descripción | Tipo | Requerido | Default |
|----------|-------------|------|-----------|---------|
| `service_name` | Nombre del servicio (api, frontend, etc.) | `string` | ✅ | - |
| `environment` | Ambiente (dev, staging, prod) | `string` | ✅ | - |
| `project_tags` | Tags a aplicar a los parámetros | `map(string)` | ✅ | - |
| `parameters` | Mapa de parámetros clave-valor a crear | `map(string)` | ✅ | - |

## 📤 Outputs

| Output | Descripción | Tipo |
|--------|-------------|------|
| `parameter_arns` | Mapa de nombres de parámetros a sus ARNs | `map(string)` |

## 💡 Ejemplo de Uso

### Servicio API
```hcl
module "api_parameters" {
  source = "./module/parameter_store"
  
  service_name = "api"
  environment  = "dev"
  project_tags = local.common_tags
  
  parameters = {
    DATABASE_URL     = "postgres://user:pass@host:5432/dbname"
    JWT_SECRET       = "super-secret-jwt-key-12345"
    API_KEY          = "external-api-key-xyz"
    REDIS_URL        = "redis://redis-cluster:6379"
    SENDGRID_API_KEY = "SG.xxxxxxxxxxxx"
  }
}
```

### Servicio Frontend
```hcl
module "frontend_parameters" {
  source = "./module/parameter_store"
  
  service_name = "frontend"
  environment  = "prod"
  project_tags = local.common_tags
  
  parameters = {
    REACT_APP_API_URL        = "https://api.example.com"
    REACT_APP_ANALYTICS_ID   = "UA-123456789"
    REACT_APP_SENTRY_DSN     = "https://xxx@sentry.io/123"
  }
}
```

## 🔍 Notas Importantes

- Los parámetros se crean con el path: `/{environment}/{service_name}/{parameter_key}`
- Todos los parámetros se almacenan como `SecureString` (cifrados)
- Usa el KMS key por defecto de AWS (`alias/aws/ssm`)
- Los valores son sensibles y no se muestran en logs de Terraform

## 🔐 Seguridad

- Los parámetros están cifrados en reposo usando KMS
- El acceso requiere permisos IAM específicos
- Los valores no se exponen en el plan de Terraform
- Ideal para cumplir con requisitos de compliance

## 🔄 Integración con ECS

Para usar estos parámetros en ECS Task Definitions:

```hcl
secrets = [
  {
    name      = "DATABASE_URL"
    valueFrom = module.api_parameters.parameter_arns["DATABASE_URL"]
  },
  {
    name      = "JWT_SECRET"
    valueFrom = module.api_parameters.parameter_arns["JWT_SECRET"]
  }
]
```

## 📝 Buenas Prácticas

1. **Nomenclatura**: Usa nombres descriptivos en MAYÚSCULAS con guiones bajos
2. **Versionado**: Parameter Store mantiene versiones automáticamente
3. **Rotación**: Actualiza los secretos regularmente
4. **Acceso**: Limita el acceso solo a los servicios que lo necesitan

## 🔗 Recursos Relacionados

- [AWS Systems Manager Parameter Store](https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-parameter-store.html)
- [ECS Secrets](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/specifying-sensitive-data.html)
- [Parameter Store vs Secrets Manager](https://docs.aws.amazon.com/systems-manager/latest/userguide/integration-ps-secretsmanager.html)