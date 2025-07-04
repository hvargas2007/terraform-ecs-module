# Módulo ECS Service

## 📋 Descripción

Este módulo crea un servicio ECS completo con todos sus componentes asociados: repositorio ECR, definición de tarea, servicio ECS y grupo de logs de CloudWatch. Es el módulo principal para desplegar aplicaciones en contenedores.

## 🎯 Recursos Creados

- `aws_ecr_repository`: Repositorio para imágenes Docker
- `aws_ecr_lifecycle_policy`: Política para limpieza automática de imágenes
- `aws_cloudwatch_log_group`: Grupo de logs para el servicio
- `aws_ecs_task_definition`: Definición de la tarea con configuración de contenedores
- `aws_ecs_service`: Servicio ECS con integración al load balancer (con soporte para manage_task_definition)

## 📥 Variables de Entrada

| Variable | Descripción | Tipo | Requerido | Default |
|----------|-------------|------|-----------|---------|
| `ecs_cluster_id` | ID del cluster ECS | `string` | ✅ | - |
| `execution_role_arn` | ARN del rol de ejecución de ECS | `string` | ✅ | - |
| `task_role_arn` | ARN del rol de la tarea | `string` | ✅ | - |
| `ecs_sg_id` | ID del security group para las tareas | `string` | ✅ | - |
| `tg_arn` | ARN del target group del ALB | `string` | ✅ | - |
| `aws_region` | Región de AWS | `string` | ✅ | - |
| `name_prefix` | Prefijo para nombres de recursos | `string` | ✅ | - |
| `project_tags` | Tags del proyecto | `map(string)` | ✅ | - |
| `vpc_id` | ID del VPC | `string` | ✅ | - |
| `subnet_private` | Lista de subnets privadas | `list(string)` | ✅ | - |
| `container_definitions` | Definición del contenedor | `list(object)` | ✅ | - |
| `name_registry` | Nombre del repositorio ECR | `string` | ✅ | - |
| `amount_of_ecr_images_to_keep` | Número de imágenes a mantener en ECR | `number` | ✅ | - |
| `scan_ecr_images_on_push` | Escanear imágenes al subirlas | `bool` | ✅ | - |
| `task_definition_name` | Nombre personalizado para la task definition | `string` | ❌ | `{container_name}-td` |
| `manage_task_definition` | Si Terraform debe gestionar cambios en la task definition | `bool` | ❌ | `true` |
| `use_external_image` | Usar imagen externa en lugar de ECR | `bool` | ❌ | `false` |

### Estructura de container_definitions

```hcl
container_definitions = [
  {
    name           = string  # Nombre del contenedor
    cpu            = number  # Unidades de CPU (1024 = 1 vCPU)
    memory         = number  # Memoria en MB
    container_port = number  # Puerto del contenedor
    desired_count  = number  # Número de tareas deseadas
    image_tag      = string  # Tag de la imagen Docker (default: "latest")
    external_image = string  # URL completa de imagen externa (opcional)
    environment = list(object({
      name  = string
      value = string
    }))
    secrets = list(object({
      name      = string  # Nombre de la variable de entorno
      valueFrom = string  # ARN del Parameter Store
    }))
    root_directory_path = string  # Path en el sistema de archivos
    log_group_name      = string  # Nombre del grupo de logs
    log_stream_prefix   = string  # Prefijo para los streams
  }
]
```

## 📤 Outputs

| Output | Descripción | Tipo |
|--------|-------------|------|
| `ecr_repository_url` | URL del repositorio ECR | `string` |
| `ecr_repository_arn` | ARN del repositorio ECR | `string` |
| `ecs_service_name` | Nombre del servicio ECS | `string` |
| `ecs_service_id` | ID del servicio ECS | `string` |
| `task_definition_arn` | ARN de la task definition | `string` |
| `service_name` | Nombre del servicio ECS (para autoscaling) | `string` |

## 💡 Ejemplo de Uso

### Servicio API
```hcl
module "api_service" {
  source = "./module/ecs_service"
  
  ecs_cluster_id     = module.ecs.ecs_cluster_id
  execution_role_arn = module.iam.execution_role_arn
  task_role_arn      = module.iam.task_role_arn
  ecs_sg_id          = module.security_groups.ecs_sg_id
  tg_arn             = module.api_targetgroup.target_group_arn
  aws_region         = "us-east-1"
  name_prefix        = "proyecto-dev"
  project_tags       = local.common_tags
  vpc_id             = var.vpc_id
  subnet_private     = var.subnet_private
  
  container_definitions = [
    {
      name           = "api-service"
      cpu            = 512
      memory         = 1024
      container_port = 80
      desired_count  = 2
      image_tag      = "v1.0.0"  # Controla la versión de la imagen
      environment = [
        {
          name  = "NODE_ENV"
          value = "production"
        }
      ]
      secrets = [
        {
          name      = "DATABASE_URL"
          valueFrom = "arn:aws:ssm:us-east-1:123456789:parameter/dev/api/DATABASE_URL"
        }
      ]
      root_directory_path = "/"
      log_group_name      = "ecs/dev/api"
      log_stream_prefix   = "api"
    }
  ]
  
  name_registry                = "api"
  amount_of_ecr_images_to_keep = 10
  scan_ecr_images_on_push      = true
  task_definition_name         = "api-task-def"
  manage_task_definition       = false  # Permite CI/CD actualizar imágenes
}
```

### Servicio con Imagen Externa
```hcl
module "external_service" {
  source = "./module/ecs_service"
  
  # ... otras configuraciones ...
  
  use_external_image = true
  container_definitions = [
    {
      name           = "nginx"
      external_image = "nginx:alpine"  # Imagen de Docker Hub
      cpu            = 256
      memory         = 512
      container_port = 80
      desired_count  = 1
      # ... resto de configuración ...
    }
  ]
}
```

## 🔍 Notas Importantes

- Las tareas usan Fargate como tipo de lanzamiento
- Los logs se retienen por 7 días por defecto
- El servicio se integra automáticamente con el target group del ALB
- Soporta tanto variables de entorno normales como secretos de Parameter Store
- Las imágenes deben subirse al repositorio ECR creado (a menos que uses `use_external_image`)
- Cuando `manage_task_definition = false`, Terraform ignora cambios en la task definition permitiendo actualizaciones por CI/CD
- El módulo crea dos recursos de servicio ECS condicionales para manejar el lifecycle correctamente

## 🐳 Proceso de Despliegue

1. **Build de la imagen**:
   ```bash
   docker build -t mi-app:latest .
   ```

2. **Tag de la imagen**:
   ```bash
   docker tag mi-app:latest {ecr_repository_url}:v1.0.0
   ```

3. **Push al ECR**:
   ```bash
   aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin {ecr_repository_url}
   docker push {ecr_repository_url}:v1.0.0
   ```

4. **Actualizar el servicio** (cuando `manage_task_definition = false`):
   ```bash
   # Opción 1: Forzar nuevo despliegue con la misma task definition
   aws ecs update-service --cluster {cluster_name} --service {service_name} --force-new-deployment
   
   # Opción 2: Actualizar a una nueva revisión de task definition
   aws ecs update-service --cluster {cluster_name} --service {service_name} --task-definition {task_def_arn}
   ```

## 🔄 Control de Versiones con image_tag

El módulo permite controlar fácilmente las versiones de las imágenes:

1. **En Terraform**: Actualiza el `image_tag` en tu configuración
2. **Via CI/CD**: Con `manage_task_definition = false`, puedes actualizar las imágenes sin tocar Terraform
3. **Tags soportados**: `latest`, `v1.0.0`, `develop`, `commit-sha`, etc.

## 🔗 Recursos Relacionados

- [ECS Task Definitions](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definitions.html)
- [ECS Services](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs_services.html)
- [ECR Lifecycle Policies](https://docs.aws.amazon.com/AmazonECR/latest/userguide/LifecyclePolicies.html)